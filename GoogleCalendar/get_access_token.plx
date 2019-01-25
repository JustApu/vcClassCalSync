#!/usr/bin/env perl

use strict ;
use warnings ;

require "calendar_functions.pl" ;

my $token = access_token() ;
print "my Access token = $token\n" ;
exit 0 ;
