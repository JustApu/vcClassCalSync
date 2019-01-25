#!/usr/bin/perl -w

# Class ID,Person ID
my @inputFiles = ('ClassCalSync_Enroll-Students.csv', 'ClassCalSync_Enroll-Teachers.csv');

# Database
$DBSVR  = 'localhost';
$DBNAME = 'classCalSync';
$DBUSER = '**username**';
$DBPASS = '**password**';
$DBTABLE1 = 'tmpEnroll';
$DBTABLE2 = 'tmpEnrollAthl';


use HTML::Entities qw(decode_entities);
use utf8;


use Text::CSV;
my $csvIn = Text::CSV_XS->new ( { sep_char => ',' } );


#Prepare use of SQL database
use DBI;
my $dsn = "DBI:mysql:$DBNAME:$DBSVR";
my $dbh = DBI->connect($dsn, $DBUSER, $DBPASS) or die ("Cannot connect");
$dbh->do("TRUNCATE TABLE $DBTABLE1");
$dbh->do("TRUNCATE TABLE $DBTABLE2");

#Insert data into database
$insert1 = $dbh->prepare("INSERT into $DBTABLE1 (Class, Person) values (?, ?)");
$insert2 = $dbh->prepare("INSERT into $DBTABLE2 (Class, Person) values (?, ?)");



foreach $inputFile (@inputFiles)
{
  open( my $readRows, '<:encoding(utf-8)', $inputFile)
    or die "Could not open $inputFile: $!\n";
  while (my $line = <$readRows>)
  {
    chomp $line;
    if ($csvIn->parse($line))
    {
      my ($classID, $personID) = $csvIn->fields();
      next if ($classID =~ m/Class ID/);

      $insert1->execute($classID, $personID);
      $insert2->execute($classID, $personID);
    }
    else { warn "Line could not be parsed: $line\n"; }
  }
}

$insert1->finish();
$insert2->finish();

exit;
