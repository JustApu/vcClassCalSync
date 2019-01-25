#!/usr/bin/env perl

use strict ;
use warnings ;

# Database
use DBI;
my $DBSERVER  = 'localhost';
my $DBNAME = 'classCalSync';
my $DBUSER = '**username**';
my $DBPASS = '**password**';
my $DBTABLE = 'tmpEnrollAthl';

##############################################################
#Prepare use of SQL database
my $dsn = "DBI:mysql:$DBNAME:$DBSERVER";
my $dbh = DBI->connect($dsn, $DBUSER, $DBPASS) or die ("Cannot connect");

# Find pending updates
my $toAdd = $dbh->prepare("select count(eventID) from toAddAthl");
$toAdd->execute();
my $numAdd = $toAdd->fetchrow_array();

my $toUpdate = $dbh->prepare("select count(eventID) from toUpdateAthl");
$toUpdate->execute();
my $numUpdate = $toUpdate->fetchrow_array();

my $toDelete = $dbh->prepare("select count(eventID) from toDeleteAthl");
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
  $dbh->do("DROP TABLE toAddAthl");
  $dbh->do("DROP TABLE toUpdateAthl");
  $dbh->do("DROP TABLE toDeleteAthl");

  # Create temporary table of all new pending updates
  $dbh->do("create temporary table toPush
select eventID,classID,eventDate,start,end,description,room,curEventsAthl.googleID
from tmpEventsAthl
left join curEventsAthl using (eventID,classID,eventDate,start,end,description,room)
where curEventsAthl.eventID is null");

  # From the temporary table, find those events we need to add
  $dbh->do("create table toAddAthl
select toPush.eventID,toPush.classID,toPush.eventDate,toPush.start,
	toPush.end,toPush.description,toPush.room,toPush.googleID
from toPush
left join curEventsAthl using (eventID)
where curEventsAthl.eventID is null");

  # From the temporary table, find those events we need to update
  $dbh->do("create table toUpdateAthl
select toPush.eventID,toPush.classID,toPush.eventDate,toPush.start,
	toPush.end,toPush.description,toPush.room,toPush.googleID
from toPush
left join toAddAthl using(eventID)
where toAddAthl.eventID is null");
  $dbh->do("update toUpdateAthl
join curEventsAthl on toUpdateAthl.eventID = curEventsAthl.eventID
set toUpdateAthl.googleID = curEventsAthl.googleID");
  $dbh->do("ALTER TABLE `toUpdateAthl` ADD UNIQUE (`eventID`)");

  # From the temporary table, find those events we need to delete
  $dbh->do("create table toDeleteAthl
select eventID,classID,eventDate,start,end,description,room, curEventsAthl.googleID
from curEventsAthl
left join tmpEventsAthl using (eventID,classID,eventDate,start,end,description,room)
where tmpEventsAthl.eventID is null");
  $dbh->do("DELETE FROM toDeleteAthl
WHERE googleID IN ( SELECT googleID FROM toUpdateAthl )");

  # Find enrollments to remove
  my $selectEvent = $dbh->prepare("
	SELECT curEnrollAthl.Class, curEnrollAthl.Person
	FROM curEnrollAthl
	LEFT JOIN tmpEnrollAthl
	ON curEnrollAthl.Class = tmpEnrollAthl.Class
	   AND curEnrollAthl.Person = tmpEnrollAthl.Person
	WHERE tmpEnrollAthl.Class IS NULL");
  $selectEvent->execute();
  while (my ($class, $person) =
	$selectEvent->fetchrow_array())
  {
    # Delete from curEnrollAthl table
    my $deleteEvent = $dbh->prepare("DELETE FROM curEnrollAthl
	WHERE `Class` = ? AND `Person` = ?");
    $deleteEvent->execute($class, $person);

    # Update toUpdateAthl table
    stageEventUpdate($class);
  }

  # Find enrollments to add
  $selectEvent = $dbh->prepare("
	SELECT tmpEnrollAthl.Class, tmpEnrollAthl.Person
	FROM tmpEnrollAthl
	LEFT JOIN curEnrollAthl
	ON curEnrollAthl.Class = tmpEnrollAthl.Class
	   AND curEnrollAthl.Person = tmpEnrollAthl.Person
	WHERE curEnrollAthl.Class IS NULL;");
  $selectEvent->execute();
  while (my ($class, $person) =
	$selectEvent->fetchrow_array())
  {
    # Add to curEnrollAthl table
    my $insertEvent = $dbh->prepare("INSERT INTO curEnrollAthl
	(`Class`, `Person`) VALUES (?, ?)");
    $insertEvent->execute($class, $person);

    # Update toUpdateAthl table
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
  my $updateEvent = $dbh->prepare("INSERT IGNORE INTO toUpdateAthl
	(`eventID`, `classID`, `eventDate`, `start`, `end`, `description`, `room`, `googleID`)
	SELECT `eventID`, `classID`, `eventDate`, `start`, `end`, `description`, `room`, `googleID`
	FROM curEventsAthl
	WHERE `classID` = ?");
  $updateEvent->execute($class);
}
