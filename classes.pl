#!/usr/bin/perl -w

# Internal Class ID,Class ID,Description,Meeting Times
my @inputFiles = ('ClassCalSync_Classes.csv');

# Database
$DBSVR  = 'localhost';
$DBNAME = 'classCalSync';
$DBUSER = '**username**';
$DBPASS = '**password**';
$DBTABLE = 'curClasses';


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
$insert = $dbh->prepare("INSERT into $DBTABLE (ID, Class) values (?, ?)");



foreach $inputFile (@inputFiles)
{
  open( my $readRows, '<:encoding(utf-8)', $inputFile)
    or die "Could not open $inputFile: $!\n";
  while (my $line = <$readRows>)
  {
    chomp $line;
    if ($csvIn->parse($line))
    {
      my ($intClassID, $classID, $desc, $meeting) = $csvIn->fields();
      next if ($intClassID =~ m/Internal Class ID/);

      $desc = decode_entities($desc);
      if ($meeting =~ m/US-\w-US-(\d)/) { $desc = $1 . " | " . $desc; }
      elsif ($meeting =~ m/\-[MU]S-([^L-]*)L?$/) { $desc = $1 . " | " . $desc; }

      $insert->execute($intClassID, $desc);
    }
    else { warn "Line could not be parsed: $line\n"; }
  }
}

$insert->finish();

exit;

