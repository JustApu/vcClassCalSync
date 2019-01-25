my $private_key_string = "-----BEGIN PRIVATE KEY-----\n***KEY DATA***\n-----END PRIVATE KEY-----\n";

my $time = time;

use LWP;
use JSON::WebToken;
use HTML::Entities;
my $jwt = JSON::WebToken->encode(
    {
        # your service account id here
        iss   => 'service-account@project-name.iam.gserviceaccount.com';
        scope => "https://www.google.com/calendar/feeds/",
        aud   => 'https://accounts.google.com/o/oauth2/token',
        exp   => $time + 3600,
        iat   => $time,
        # To access the google admin sdk with a service account
        # the service account must act on behalf of an account
        # that has admin privileges on the domain
        # Otherwise the token will be returned but API calls
        # will generate a 403
        prn => 'user@school.org',
    },
    $private_key_string,
    'RS256',
    { typ => 'JWT' }
);

# Now post it to google
my $ua       = LWP::UserAgent->new();
my $response = $ua->post(
    'https://accounts.google.com/o/oauth2/token',
    {   grant_type => encode_entities('urn:ietf:params:oauth:grant-type:jwt-bearer'),
        assertion  => $jwt
    }
);

#unless ( $response->is_success() ) {
    die( $response->code, "\n", $response->content, "\n" );
#}

