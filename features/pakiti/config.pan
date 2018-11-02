unique template features/pakiti/config;

# Define in case this is not a grid machine and it has not already been defined
variable SITE_DEF_CERTDIR ?= '/etc/grid-security/certificates';

@{
desc = directory containing CA definitions and CRLs
values = directory path
default = /etc/grid-security/certificates
required = no
}
variable PAKITI_CA_PATH ?= SITE_DEF_CERTDIR;

@{
desc = Pakiti server host name
values = host name FQDN
default = none
required = yes
}
variable PAKITI_SERVER ?= error('PAKITI_SERVER variable undefined: no default');

@{
desc = Pakiti port on server
values = port number
default = 443
required = no
}
variable PAKITI_SERVER_PORT ?= 443;

@{
desc = Pakiti tag to used for this machine
values = string
default = none
required = no
}
variable PAKITI_TAG ?= 'none';

@{
desc = Pakiti feed URL on the server
values = URL (host specific part)
default = /feed
required = no
}
variable PAKITI_SERVER_FEED_URL ?= "/feed/";
variable PAKITI_SERVER_FEED_URL = {
    if ( !match(SELF, '^/') ) {
        error('PAKITI_SERVER_FEED_URL must start with a /');
    };
    if ( !match(SELF, '/$') ) {
        SELF + '/';
    } else {
        SELF;
    };
};


include 'security/cas';
include 'features/fetch-crl/config';

include { if ( PAKITI_SERVER == FULL_HOSTNAME ) {
    'features/pakiti/server';
}};

include 'features/pakiti/client/config';
