package AuthInfo;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw[$private_key
  $service_acct $service_scope $service_aud $service_person $service_url
  $base_url $calendar_list_url $DBSERVER $DBNAME $DBUSER $DBPASS];

our $private_key = "-----BEGIN PRIVATE KEY-----
***KEY DATA***
-----END PRIVATE KEY-----
";

our $service_acct = 'service-account@project-name.iam.gserviceaccount.com';
our $service_scope = 'https://www.google.com/calendar/feeds/';
our $service_aud = 'https://accounts.google.com/o/oauth2/token';
our $service_person = 'user@school.org';
our $service_url = 'https://accounts.google.com/o/oauth2/token';

our $base_url = 'https://www.googleapis.com/calendar/v3/calendars/' ;
our $calendar_list_url = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';

use DBI;
our $DBSERVER  = 'localhost';
our $DBNAME = 'classCalSync';
our $DBUSER = '**username**';
our $DBPASS = '**password**';

1;
