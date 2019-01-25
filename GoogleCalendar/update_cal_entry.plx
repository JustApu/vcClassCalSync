#!/usr/bin/env perl

use strict ;
use warnings ;

use AuthInfo;
require "calendar_functions.pl" ;

my $agent         = "ClassCalSync/0.9" ;
my $timezone      = "America/New_York" ;
my $defaultsleep  = 10;	# How long to sleep if we get a 403 from Google
my $maxsleep      = 300;
my $sleeptimer    = $defaultsleep;

# Get list of all calendars in target account
my $cal_data = get_calendar_list_data( $agent ) ;
if ( $cal_data =~ /^Error/ ) {
    print "$cal_data\n" ;
    exit(1) ;
}

# Get calendar ID for target calendar
my $cal_name = 'user\@school.org' ;
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
	DELETE from `toUpdate`
	WHERE `eventDate` < ?");
$deleteEvent->execute(todayInSQL());


# Find each class meeting we need to update
my $selectEvent = $dbh->prepare("
	SELECT eventID, classID, eventDate, start, end, description, room, googleID
	FROM `toUpdate`
        WHERE `eventDate` >= ?   
        ORDER BY `eventDate`,`start`");
$selectEvent->execute(todayInSQL());
while (my ($eventID, $classID, $eventDate, $start, $end, $description, $room, $googleID) =
	$selectEvent->fetchrow_array())
{
  # Get name of the class
  my $selectClass = $dbh->prepare("
	SELECT Class FROM `curClasses` WHERE `ID` = ?");
  $selectClass->execute($classID);
  my ($summary) = $selectClass->fetchrow_array();

  # For each class, get current enrollees
  my $selectEnrollees = $dbh->prepare("
	SELECT curPersons.Email FROM `curEnroll`
	INNER JOIN curPersons ON curEnroll.Person = curPersons.ID
	WHERE curEnroll.Class = ?");
  my @attendees;
  $selectEnrollees->execute($classID);
  while (my $attendee = $selectEnrollees->fetchrow_array())
  { push (@attendees, {'email' => $attendee, 'responseStatus' => 'accepted'}); }

  # Invite room
  my $selectRoom = $dbh->prepare("
	SELECT email
	FROM `curRooms`
	WHERE `name` = ?");
  $selectRoom->execute($room);
  while (my $roomEmail = $selectRoom->fetchrow_array())
  { push (@attendees, {'email' => $roomEmail, 'responseStatus' => 'accepted'}); }

  # Build Perl object for each event
  my $event = {
	attendees => \@attendees,
	location => $room,
	description => $description,
	reminders => {
		'useDefault' => 'false'
	},
	SingleEvents => '1',
	colorId => '4',
	end => {
		'dateTime' => "${eventDate}T${end}.000",
		'timeZone' => "America/New_York"
	},
	start => {
		'dateTime' => "${eventDate}T${start}.000",
		'timeZone' => "America/New_York"
	},
	summary => $summary
  };


  # Encode Perl object into JSON object
  my $event_json = encode_json($event);

  # Post JSON object to Google
  my $post = update_cal_entry( $event_json, $id, $googleID ) ;
  if ( $post =~ /^Error/ ) {
    print "$post\n" ;
    if ( $post =~ /Forbidden \(403\)/ )
    {
      if ($sleeptimer < $maxsleep)
      { $sleeptimer = int($sleeptimer * (1 + rand(1))); }
      print "Sleeping $sleeptimer seconds\n\n";
      sleep( $sleeptimer );
      next;
    }
    else
    { 
      print Dumper(decode_json($event_json));
      exit(1);
    }
  }
  else
  {
    # Get Google calendar event ID and status of submission
    my ($googleID, $googleStatus) = $post =~ m/(.*) is (.*)/;

    if ($googleStatus =~ m/confirmed/)
    {
      # Update curEvents
      my $updateEvent = $dbh->prepare("UPDATE curEvents
	SET `classID` = ?, `eventDate` = ?,
	`start` = ?, `end` = ?, `description` = ?, `room` = ?
	WHERE `eventID` = ? AND `googleID` = ?");
      $updateEvent->execute($classID, $eventDate, $start, $end,
        $description, $room, $eventID, $googleID);

      # Delete event from toUpdate table
      my $deleteEvent = $dbh->prepare("DELETE from toUpdate WHERE eventID = ?");
      $deleteEvent->execute($eventID);
    }

    # Pause between events
    usleep(10000);
  }
}

exit 0 ;
