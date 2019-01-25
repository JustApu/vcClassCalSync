#!/usr/bin/perl

use JSON;
use Data::Dumper;

use DBI;
my $DBSERVER  = 'localhost';
my $DBNAME = 'classCalSync';
my $DBUSER = '**username**';
my $DBPASS = '**password**';
my $DBTABLE = 'curRooms';


##############################################################
# Prepare use of SQL database
my $dsn = "DBI:mysql:$DBNAME:$DBSERVER";
my $dbh = DBI->connect($dsn, $DBUSER, $DBPASS) or die ("Cannot connect");
$dbh->do("TRUNCATE TABLE $DBTABLE");


##############################################################
# Get data
my $data;
{
    local $/ = undef;
    open my $fh, '<', 'rooms.json';
    $data = <$fh>;
    close $fh;
}


##############################################################
# Insert into table
my $result = decode_json( $data );
my $insert = $dbh->prepare("INSERT into curRooms
        (name, email) values (?, ?)");

for my $item( @{$result->{items}} ){
  $insert->execute($item->{resourceName}, $item->{resourceEmail});
};
