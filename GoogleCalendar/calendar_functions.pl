#!/usr/bin/env perl

# A bunch of functions for use with the Google Calendar v3 API using REST
#
# Copyright 2014 RJ White (rj@moxad.com, Nov. 2014)
# https://github.com/rjwhite/Google-Calendar-Perl-access
#
# Modifications Copyright 2018 Apu <apu@pingry.org> (Aug. 2018)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


use strict ;
use warnings ;

use Data::Dumper;
use LWP;
use LWP::UserAgent;
use JSON;
use JSON::WebToken;
use HTML::Entities;
use POSIX 'strftime';
use Time::HiRes qw(usleep);
use URI::Encode qw(uri_encode uri_decode);
use utf8;


use AuthInfo;       # Perl package with authentication info
my $C_ERROR = "Error:" ;


# Return today's date in YYYY-MM-DD format
#
sub todayInSQL {
  return strftime '%Y-%m-%d', localtime;
}


# create a calendar entry
#
# Inputs:
#   1:  JSON structure of calendar entry
#   2:  calendar ID
#   3:  agent - can be undefined or empty string
# Output:
#   status              if ok
#   $C_ERROR: msg       if not ok

sub create_cal_entry {
    my $cal_entry   = shift ;
    my $cal_id      = shift ;
    my $agent       = shift ;

    my $i_am = "create_cal_entry()" ;
    if (( not defined( $cal_entry )) or ( $cal_entry eq "" )) {
        return( "${C_ERROR} $i_am: JSON calendar entry undefined or empty string" ) ;
    }
    if (( not defined( $cal_id )) or ( $cal_id eq "" )) {
        return( "${C_ERROR} $i_am: Calendar ID undefined or empty string" ) ;
    }

    my $url      = "${base_url}${cal_id}/events" ;

    my $ua = LWP::UserAgent->new ;
    if (( defined( $agent )) && ( $agent ne "" )) {
        $ua->agent( $agent ) ;
    }
    $ua->default_header( Authorization => 'Bearer ' . access_token() ) ;

    my $req = HTTP::Request->new( POST => $url ) ;
    $req->content_type( 'application/json' ) ;

    $req->content( $cal_entry ) ;

    # Pass request to the user agent and get a response back
    my $res  = $ua->request( $req ) ;
    my $code = $res->code ;
    my $msg  = $res->message ;

    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: Content not defined" ) ;
        }

        if ( $res->content =~ /^{/ ) {
            # seems to be a JSON string.
            my $r = from_json( $res->content ) ;
            my $id = $r->{ 'id' } ;
            my $status = $r->{ 'status' } ;
            return( "$id is $status" ) ;
        } else {
            # must be a ordinary string
            return( "success" ) ;       # shouldn't happen?
        }
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $msg ($code)" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code)" ) ;
    }
}


# update a calendar entry
#
# Inputs:
#   1:  JSON structure of calendar entry
#   2:  calendar ID
#   3:  event ID to be updated
#   4:  agent - can be undefined or empty string
# Output:
#   status              if ok
#   $C_ERROR: msg       if not ok

sub update_cal_entry {
    my $cal_entry   = shift ;
    my $cal_id      = shift ;
    my $event_id    = shift ;
    my $agent       = shift ;

    my $i_am = "update_cal_entry()" ;
    if (( not defined( $cal_entry )) or ( $cal_entry eq "" )) {
        return( "${C_ERROR} $i_am: JSON calendar entry undefined or empty string (Arg 1)" ) ;
    }
    if (( not defined( $cal_id )) or ( $cal_id eq "" )) {
        return( "${C_ERROR} $i_am: Calendar ID undefined or empty string (Arg 3)" ) ;
    }
    if (( not defined( $event_id )) or ( $event_id eq "" )) {
        return( "${C_ERROR} $i_am: Event ID undefined or empty string (Arg 4)" ) ;
    }

    my $url      = "${base_url}${cal_id}/events/${event_id}" ;

    my $ua = LWP::UserAgent->new ;
    if (( defined( $agent )) && ( $agent ne "" )) {
        $ua->agent( $agent ) ;
    }
    $ua->default_header( Authorization => 'Bearer ' . access_token() ) ;

    my $req = HTTP::Request->new( PUT => $url ) ;
    $req->content_type( 'application/json' ) ;

    $req->content( $cal_entry ) ;

    # Pass request to the user agent and get a response back
    my $res  = $ua->request( $req ) ;
    my $code = $res->code ;
    my $msg  = $res->message ;

    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: Content not defined" ) ;
        }

        if ( $res->content =~ /^{/ ) {
            # seems to be a JSON string.
            my $r = from_json( $res->content ) ;
            my $id = $r->{ 'id' } ;
            my $status = $r->{ 'status' } ;
            return( "$id is $status" ) ;
        } else {
            # must be a ordinary string
            return( "success" ) ;       # shouldn't happen?
        }
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $url returned $msg ($code)" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code)" ) ;
    }
}


# Send a GET HTTP request.
#
# Input:
#   1:  URL - http://what.ever
#   2:  agent - can be undefined or empty string
# Output:
#   string          if ok
#   $C_ERROR: msg   if not ok

sub get_request {
    my $url     = shift ;
    my $agent   = shift ;

    my $i_am = "get_request()" ;

    if (( not defined( $url )) or ( $url eq "" )) {
        return( "${C_ERROR} $i_am: URL is undefined or empty string" );
    }

    my $ua = LWP::UserAgent->new ;
    if (( defined( $agent )) && ( $agent ne "" )) {
        $ua->agent( $agent ) ;
    }
    $ua->default_header( Authorization => 'Bearer ' . access_token() ) ;

    # Create a request
    my $req = HTTP::Request->new( GET => $url ) ;

    # Pass request to the user agent and get a response back
    my $res  = $ua->request( $req );
    my $code = $res->code ;
    my $msg  = $res->message ;

    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: return content not defined for $url" ) ;
        }
        if ( $res->content eq "" ) {
            return( "${C_ERROR} $i_am: return content empty string for $url" ) ;
        }
        return( $res->content ) ;
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $msg ($code) for $url" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code) for $url" ) ;
    }
}



# Get an access token using OAuth2 & service account previously set up.
#
# Inputs:
#   none
# Output:
#   access_token    if ok
#   $C_ERROR: msg   if not ok

sub access_token {
    my $i_am = "access_token()" ;
    my $data = "" ;

my $time = time;

my $jwt = JSON::WebToken->encode(
    {
        iss   => $service_acct,
        scope => $service_scope,
        aud   => $service_aud,
        exp   => $time + 3600,
        iat   => $time,
        prn   => $service_person,
    },
    $private_key,
    'RS256',
    { typ => 'JWT' }
);

# Now post it to google
my $ua       = LWP::UserAgent->new();
my $response = $ua->post($service_url,
    {   grant_type => encode_entities('urn:ietf:params:oauth:grant-type:jwt-bearer'),
        assertion  => $jwt
    }
);

    # Check the outcome of the response
    if ( $response->is_success ) {
        my $ref = from_json( $response->content ) ;
        my $access_token = ${$ref}{ 'access_token' } ;
        return( $access_token ) ;
    } else {
        if($response->code() eq '501') {
           # E.g. LWP::Protocol::https not installed
           return( "${C_ERROR} $i_am: " . $response->message);
        }
        else {
           return( "${C_ERROR} $i_am: " . $response->status_line );
        }
    }
}


# See if a time slot is already booked
#
# Inputs:
#   bookings string - returned by get_bookings()
# Output:
#   count of bookings.  0 = no bookings
#   $C_ERROR: msg       if not ok

sub is_booked {
    my $bookings = shift ;

    my $i_am = "is_booked()" ;
    if (( not defined( $bookings )) or ( $bookings eq "" )) {
        return( "${C_ERROR} $i_am: bookings (Arg 1) is undefined or empty string" ) ;
    }

    if ( $bookings =~ /^{/ ) {
        # seems to be a JSON string.
        my $ref = from_json( $bookings ) ;
        my $items_ref = ${$ref}{ "items" } ;
        if ( not defined( $items_ref )) {
            return( "${C_ERROR} $i_am: did not find items in bookings" ) ;
        }
        my $num = 0 ;
        foreach my $array_ref ( @{$items_ref} ) {
            $num++ ;
        }
        return( $num ) ;
    } else {
        return( "${C_ERROR} $i_am: did not find JSON string to parse" ) ;
    }
}


# Get bookings
#
# Inputs:
#   1:  date:               YYYY-MM-DD  eg: 2014-12-09
#   2:  start date:         HH:mm       eg: 12:00
#   3:  end-date:           HH:mm       eg: 14:30
#   4:  timezone:           +/-DD:DD    eg: -05:00
#   5:  calendar-ID
#   6:  agent - can be empty string
#   7:  (optional) string of comma separated fields we want
# Output:
#   JSON string of bookings

sub get_bookings {
    my $date        = shift ;
    my $start_time  = shift ;
    my $end_time    = shift ;
    my $timezone    = shift ;
    my $cal_id      = shift ;
    my $agent       = shift ;
    my $fields      = shift ;

    my $i_am   = "get_bookings()" ;

    # argument sanity checking.  These are all scalars
    my %args_check = (
        "Date (Arg 1)"          => \$date,
        "Start time (Arg 2)"    => \$start_time,
        "End time (Arg 3)"      => \$end_time,
        "timezone (Arg 4)"      => \$timezone,
        "calendar ID (Arg 5)"   => \$cal_id,
    ) ;
    foreach my $err( keys( %args_check )) {
        my $addr = $args_check{ $err } ;
        if ( not defined( ${$addr} )) {
            return( "${C_ERROR} $i_am: $err is undefined" ) ;
        }
        if ( ${$addr} eq "" ) {
            return( "${C_ERROR} $i_am: $err is a empty string" ) ;
        }
    }

    if ( not defined( $fields )) {
        $fields = "" ;
    }

    my $request = $base_url ;
    my $start   = $date . 'T' . $start_time . ":00.000${timezone}";
    my $end     = $date . 'T' . $end_time . ":00.000${timezone}";

    # build up request

    $request .= uri_encode($cal_id, {encode_reserved => 1}) . '/events?' ;
    $request .= 'timeMax=' . uri_encode($end, {encode_reserved => 1}) ;
    $request .= '&timeMin=' . uri_encode($start, {encode_reserved => 1}) ;
    $request .= '&singleEvents=true' ;

    # if user gave a restricted bumch of fields, provide them
    if ( $fields ne "" ) {
        $request .= '&fields=items(' . $fields . ')' ;
    }

    return( get_request( $request, $agent )) ;
}


# get JSON data of our calendars
#
# Input:
#   agent - can be empyty string
# Output:
#   string          if ok
#   $C_ERROR: msg   if not ok

sub get_calendar_list_data {
    my $agent   = shift ;

    my $url = $calendar_list_url ;

    my $str = get_request( $url, $agent ) ;

    return( $str ) ;
}

# get a calendar ID
#
# Inputs:
#   1:  calendar data - from get_calendar_list()
#   2:  name of calendar.    eg: 'Appointments'
# Output:
#   ID                  if ok
#   $C_ERROR: msg       if not ok

sub get_calendar_id {
    my $cal_data    = shift ;
    my $name        = shift ;

    my $i_am = "get_calendar_id()" ;

    if ( $cal_data !~ /^{/ ) {
        return( "${C_ERROR} $i_am: Calendar data (Arg 1) is not a JSON string" ) ;
    }
    if (( not defined( $name )) or ( $name eq "" )) {
        return( "${C_ERROR} $i_am: name (Arg 2) is undefined or empty string" ) ;
    }

    my $ref = from_json( $cal_data ) ;
    my $items_ref = ${$ref}{ "items" } ;
    if ( not defined( $items_ref )) {
        return( "${C_ERROR} $i_am: missing \'items\' in JSON calendar data" ) ;
    }
    my $num   = 0 ;
    my $found = 0 ;
    my $id    = "" ;
    foreach my $array_ref ( @{$items_ref} ) {
        $num++ ;
        my $summary = ${$array_ref}{ 'summary' } ;
        if ( $summary =~ /$name/i ) {
            $found++ ;
            $id = ${$array_ref}{ 'id' } ;
            if (( not defined( $id )) or ( $id eq "" )) {
                my $err = "calendar ID undefined or empty string for \'$name\'" ;
                return( "${C_ERROR} $i_am: $err" ) ;
            }
            last ;
        }
    }
    if ( $num == 0 ) {
        return( "${C_ERROR} $i_am: No calendar items found" ) ;
    }
    if ( $found == 0 ) {
        return( "${C_ERROR} $i_am: No calendar found for \'$name\'" ) ;
    }
    return( $id ) ;
}

# delete a calendar entry
#
# Inputs:
#   1:  calendar ID
#   2:  event ID to be updated
#   3:  agent - can be undefined or empty string
# Output:
#   status              if ok
#   $C_ERROR: msg       if not ok

sub delete_cal_entry {
    my $cal_id      = shift ;
    my $event_id    = shift ;
    my $agent       = shift ;

    my $i_am = "delete_cal_entry()" ;
    if (( not defined( $cal_id )) or ( $cal_id eq "" )) {
        return( "${C_ERROR} $i_am: Calendar ID undefined or empty string (Arg 1)" ) ;
    }
    if (( not defined( $event_id )) or ( $event_id eq "" )) {
        return( "${C_ERROR} $i_am: Event ID undefined or empty string (Arg 2)" ) ;
    }

    my $url      = "${base_url}${cal_id}/events/${event_id}" ;

    my $ua = LWP::UserAgent->new ;
    if (( defined( $agent )) && ( $agent ne "" )) {
        $ua->agent( $agent ) ;
    }
    $ua->default_header( Authorization => 'Bearer ' . access_token() ) ;

    my $req = HTTP::Request->new( DELETE => $url ) ;

    # Pass request to the user agent and get a response back
    my $res  = $ua->request( $req ) ;
    my $code = $res->code ;
    my $msg  = $res->message ;

    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: Content not defined" ) ;
        }

        if ( $res->content =~ /^{/ ) {
            # seems to be a JSON string.
            my $r = from_json( $res->content ) ;
            my $id = $r->{ 'id' } ;
            my $status = $r->{ 'status' } ;
            return( "$id is $status" ) ;
        } else {
            # must be a ordinary string
            return( "success" ) ;       # shouldn't happen?
        }
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $msg ($code)" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code)" ) ;
    }
}

# update a calendar resource
#
# Inputs:
#   1:  JSON structure of calendar entry
#   2:  calendar ID
#   4:  agent - can be undefined or empty string
# Output:
#   status              if ok
#   $C_ERROR: msg       if not ok
        
sub update_cal_resource {
    my $cal_entry   = shift ;
    my $cal_id      = shift ;
    my $agent       = shift ;

    my $i_am = "update_cal_resource()" ;
    if (( not defined( $cal_entry )) or ( $cal_entry eq "" )) {
        return( "${C_ERROR} $i_am: JSON calendar entry undefined or empty string (Arg 1)" ) ;
    }
    if (( not defined( $cal_id )) or ( $cal_id eq "" )) {
        return( "${C_ERROR} $i_am: Calendar ID undefined or empty string (Arg 3)" ) ;
    }
        
    my $url      = "${base_url}${cal_id}" ;
    
    my $ua = LWP::UserAgent->new ;
    if (( defined( $agent )) && ( $agent ne "" )) {
        $ua->agent( $agent ) ;
    }
    $ua->default_header( Authorization => 'Bearer ' . access_token() ) ;
    
    my $req = HTTP::Request->new( PUT => $url ) ;
    $req->content_type( 'application/json' ) ;
    
    $req->content( $cal_entry ) ;
     
    # Pass request to the user agent and get a response back 
    my $res  = $ua->request( $req ) ;
    my $code = $res->code ;
    my $msg  = $res->message ;
    
    # Check the outcome of the response
    if ( $res->is_success ) {
        if ( not defined(  $res->content )) {
            return( "${C_ERROR} $i_am: Content not defined" ) ;
        }
    
    	if ( $res->content =~ /^{/ ) {
            # seems to be a JSON string.
            my $r = from_json( $res->content ) ;
            my $id = $r->{ 'id' } ;
            my $status = $r->{ 'status' } ;
            return( "$id is $status" ) ;
        } else {
            # must be a ordinary string
            return( "success" ) ;	# shouldn't happen?
        }
    } elsif ( $res->is_error ) {
        return( "${C_ERROR} $i_am: $url returned $msg ($code)" ) ;
    } else {
        return( "${C_ERROR} $i_am: unknown state: $msg ($code)" ) ;
    }
}

1;
