#!/usr/bin/perl -w

# Person ID,Full Name,Email 1
my @inputFiles = ('ClassCalSync_Persons-Students.csv', 'ClassCalSync_Persons-Teachers.csv');

# Database
$DBSVR  = 'localhost';
$DBNAME = 'classCalSync';
$DBUSER = '**username**';
$DBPASS = '**password**';
$DBTABLE = 'curPersons';


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
$insert = $dbh->prepare("INSERT into $DBTABLE (ID, Email) values (?, ?)");



foreach $inputFile (@inputFiles)
{
  open( my $readRows, '<:encoding(utf-8)', $inputFile)
    or die "Could not open $inputFile: $!\n";
  while (my $line = <$readRows>)
  {
    chomp $line;
    if ($csvIn->parse($line))
    {
      my ($personID, $name, $email) = $csvIn->fields();
      next if ($email =~ m/Email 1/);

      $name = decode_entities($name);

      $insert->execute($personID, $email);
    }
    else { warn "Line could not be parsed: $line\n"; }
  }
}

$insert->finish();

exit;
