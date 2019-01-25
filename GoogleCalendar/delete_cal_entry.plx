#!/usr/bin/env perl

use strict ;
use warnings ;

use AuthInfo;
require "calendar_functions.pl" ;

my $agent       = "ClassCalSync/0.9" ;
my $timezone    = "America/New_York" ;

# Get list of all calendars in target account
my $cal_data = get_calendar_list_data( $agent ) ;
if ( $cal_data =~ /^Error/ ) {
    print "$cal_data\n" ;
    exit(1) ;
}

# Get calendar ID for target calendar
my $cal_name = 'classcalendar\@pingry.org' ;
my $id = get_calendar_id( $cal_data, $cal_name ) ;
if ( $id =~ /^Error/ ) {
    print "$id\n" ;
    exit(1) ;
}

##############################################################
#Prepare use of SQL database
my $dsn = "DBI:mysql:$DBNAME:$DBSERVER";
my $dbh = DBI->connect($dsn, $DBUSER, $DBPASS) or die ("Cannot connect");

# Delete events	older than today
my $deleteEvent	= $dbh->prepare("
	DELETE from `toDelete`
	WHERE `eventDate` < ?");
$deleteEvent->execute(todayInSQL());


# Find each class meeting we need to update
my $selectEvent = $dbh->prepare("
	SELECT eventID, googleID
	FROM `toDelete`
        WHERE `eventDate` >= ?   
        ORDER BY `eventDate`,`start`");
$selectEvent->execute(todayInSQL());
while (my ($eventID, $googleID) =
	$selectEvent->fetchrow_array())
{
  # Post JSON object to Google
  my $post = delete_cal_entry( $id, $googleID ) ;
  if ( $post =~ /^Error/ ) {
    print "$post\n" ;
    exit(1) ;
  }

  if ($post =~ m/success/)
  {
    # Update curEvents
    my $updateEvent = $dbh->prepare("DELETE from curEvents
	WHERE `eventID` = ? AND `googleID` = ?");
    $updateEvent->execute($eventID, $googleID);

    # Delete event from toDelete table
    my $deleteEvent = $dbh->prepare("DELETE from toDelete
	WHERE `eventID` = ? AND `googleID` = ?");
    $deleteEvent->execute($eventID, $googleID);
  }
  else
  { print "$post\n"; }

  # Pause between events
  usleep(10000);
}

exit 0 ;
