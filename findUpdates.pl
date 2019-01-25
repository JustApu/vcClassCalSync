#!/usr/bin/env perl

use strict ;
use warnings ;

# Database
use DBI;
my $DBSERVER  = 'localhost';
my $DBNAME = 'classCalSync';
my $DBUSER = '**username**';
my $DBPASS = '**password**';
my $DBTABLE = 'tmpEnroll';

##############################################################
#Prepare use of SQL database
my $dsn = "DBI:mysql:$DBNAME:$DBSERVER";
my $dbh = DBI->connect($dsn, $DBUSER, $DBPASS) or die ("Cannot connect");

# Find pending updates
my $toAdd = $dbh->prepare("select count(eventID) from toAdd");
$toAdd->execute();
my $numAdd = $toAdd->fetchrow_array();

my $toUpdate = $dbh->prepare("select count(eventID) from toUpdate");
$toUpdate->execute();
my $numUpdate = $toUpdate->fetchrow_array();

my $toDelete = $dbh->prepare("select count(eventID) from toDelete");
$toDelete->execute();
my $numDelete = $toDelete->fetchrow_array();

if ($numAdd + $numUpdate + $numDelete)
{
  print "Updates pending
Add:\t$numAdd
Update:\t$numUpdate
Delete:\t$numDelete\n"; 
  exit 0;
}
else
{
  # Zero old updates pending so DROP now empty tables
  $dbh->do("DROP TABLE toAdd");
  $dbh->do("DROP TABLE toUpdate");
  $dbh->do("DROP TABLE toDelete");

  # Create temporary table of all new pending updates
  $dbh->do("create temporary table toPush
select eventID,classID,eventDate,start,end,description,room,curEvents.googleID
from tmpEvents
left join curEvents using (eventID,classID,eventDate,start,end,description,room)
where curEvents.eventID is null");

  # From the temporary table, find those events we need to add
  $dbh->do("create table toAdd
select toPush.eventID,toPush.classID,toPush.eventDate,toPush.start,
	toPush.end,toPush.description,toPush.room,toPush.googleID
from toPush
left join curEvents using (eventID)
where curEvents.eventID is null");

  # From the temporary table, find those events we need to update
  $dbh->do("create table toUpdate
select toPush.eventID,toPush.classID,toPush.eventDate,toPush.start,
	toPush.end,toPush.description,toPush.room,toPush.googleID
from toPush
left join toAdd using(eventID)
where toAdd.eventID is null");
  $dbh->do("update toUpdate
join curEvents on toUpdate.eventID = curEvents.eventID
set toUpdate.googleID = curEvents.googleID");
  $dbh->do("ALTER TABLE `toUpdate` ADD UNIQUE (`eventID`)");

  # From the temporary table, find those events we need to delete
  $dbh->do("create table toDelete
select eventID,classID,eventDate,start,end,description,room, curEvents.googleID
from curEvents
left join tmpEvents using (eventID,classID,eventDate,start,end,description,room)
where tmpEvents.eventID is null");
  $dbh->do("DELETE FROM toDelete
WHERE googleID IN ( SELECT googleID FROM toUpdate )");

  # Find enrollments to remove
  my $selectEvent = $dbh->prepare("
	SELECT curEnroll.Class, curEnroll.Person
	FROM curEnroll
	LEFT JOIN tmpEnroll
	ON curEnroll.Class = tmpEnroll.Class
	   AND curEnroll.Person = tmpEnroll.Person
	WHERE tmpEnroll.Class IS NULL");
  $selectEvent->execute();
  while (my ($class, $person) =
	$selectEvent->fetchrow_array())
  {
    # Delete from curEnroll table
    my $deleteEvent = $dbh->prepare("DELETE FROM curEnroll
	WHERE `Class` = ? AND `Person` = ?");
    $deleteEvent->execute($class, $person);

    # Update toUpdate table
    stageEventUpdate($class);
  }

  # Find enrollments to add
  $selectEvent = $dbh->prepare("
	SELECT tmpEnroll.Class, tmpEnroll.Person
	FROM tmpEnroll
	LEFT JOIN curEnroll
	ON curEnroll.Class = tmpEnroll.Class
	   AND curEnroll.Person = tmpEnroll.Person
	WHERE curEnroll.Class IS NULL;");
  $selectEvent->execute();
  while (my ($class, $person) =
	$selectEvent->fetchrow_array())
  {
    # Add to curEnroll table
    my $insertEvent = $dbh->prepare("INSERT INTO curEnroll
	(`Class`, `Person`) VALUES (?, ?)");
    $insertEvent->execute($class, $person);

    # Update toUpdate table
    stageEventUpdate($class);  
  }

  exit 0 ;
}


# -----------------------------------------------
# Subroutines
sub stageEventUpdate
{
  my ($class) = @_;

  # Update toUpdate table
  my $updateEvent = $dbh->prepare("INSERT IGNORE INTO toUpdate
	(`eventID`, `classID`, `eventDate`, `start`, `end`, `description`, `room`, `googleID`)
	SELECT `eventID`, `classID`, `eventDate`, `start`, `end`, `description`, `room`, `googleID`
	FROM curEvents
	WHERE `classID` = ?");
  $updateEvent->execute($class);
}
