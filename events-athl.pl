#!/usr/bin/perl -w

# Event ID,Class Link,Calendar Date,Start Time,End Time,Opponent,Room
my @inputFiles = ('ClassCalSync_Athletic-Events.csv');

# Database
$DBSVR  = 'localhost';
$DBNAME = 'classCalSync';
$DBUSER = '**username**';
$DBPASS = '**password**';
$DBTABLE = 'tmpEventsAthl';


use Digest::MD5 qw(md5_base64);
use HTML::Entities qw(decode_entities);
use utf8;


use Text::CSV;
my $csvIn = Text::CSV_XS->new ( { sep_char => ',' } );


#Prepare use of SQL database
use DBI;
my $dsn = "DBI:mysql:$DBNAME:$DBSVR";
my $dbh = DBI->connect($dsn, $DBUSER, $DBPASS) or die ("Cannot connect");
$dbh->do("TRUNCATE TABLE $DBTABLE");

#Insert data into database
$insert = $dbh->prepare("INSERT into $DBTABLE
	(eventID, classID, eventDate, start, end, description, room)
	values (?, ?, ?, ?, ?, ?, ?)");



foreach $inputFile (@inputFiles)
{
  open( my $readRows, '<:encoding(utf-8)', $inputFile)
    or die "Could not open $inputFile: $!\n";
  while (my $line = <$readRows>)
  {
    chomp $line;
    if ($csvIn->parse($line))
    {
      my ($eventID, $classLink, $eventDate, $start, $end, $description, $room)
        = $csvIn->fields();
      next if ($eventID =~ m/Event ID/);

      my ($classID) = $classLink =~ m|detail/148/(\d+)|;

      $end = $start;
      next unless ($eventDate =~ m/2019\-01\-/);

      $eventHash = md5_base64($classID . $eventDate . $start . $end);
      $insert->execute($eventHash, $classID, $eventDate, $start, $end, $description, $room)
	|| warn "Error inserting $eventDate $start $description\n";
    }
    else { warn "Line could not be parsed: $line\n"; }
  }
}

$insert->finish();

exit;
