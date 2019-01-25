#!/usr/bin/perl -w

# Event ID,Class ID,Calendar Date,Start Time,End Time,Day,Block,Room
my @inputFiles = ('ClassCalSync_Events.csv');

# Database
$DBSVR  = 'localhost';
$DBNAME = 'classCalSync';
$DBUSER = '**username**';
$DBPASS = '**password**';
$DBTABLE = 'tmpEvents';


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
      my ($eventID, $classID, $eventDate, $start, $end, $day, $block, $room)
        = $csvIn->fields();
      next if ($classID =~ m/Class ID/);

      my ($description) = "Day: $day";
      if ($block !~ m/None Specified/) { $description .= ", Block: $block" }

      $eventHash = md5_base64($classID . $eventDate . $start . $end);
      $insert->execute($eventHash, $classID, $eventDate, $start, $end, $description, $room);
    }
    else { warn "Line could not be parsed: $line\n"; }
  }
}

$insert->finish();

exit;
