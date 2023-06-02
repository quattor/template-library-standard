unique template features/pakiti/client/config;

variable PAKITI_RPMS ?= if_exists('config/pakiti/client/config');
variable PAKITI_RPMS ?= 'features/pakiti/client/rpms';
include PAKITI_RPMS;

variable PAKITI_TAG ?= error('PAKITI_TAG is a mandatory variable');
variable PAKITI_SERVER ?=  error('PAKITI_SERVER is a mandatory variable');
variable PAKITI_SERVER_PROTOCOL ?= 'https';
variable PAKITI_SERVER_HTTP_PORT ?= 443;
variable PAKITI_SERVER_HTTP_FEED_URL ?= '/feed/';
variable PAKITI_SERVER_PUB_KEY_FILE ?= '/etc/pakiti/client/server-pub-key.pem';
variable PAKITI_SERVER_PUB_KEY_SOURCE ?= 'features/pakiti/client/server-pub-key.pem';
variable PAKITI_SERVER_CERTIFICATION_CHAIN_FILE ?= '/etc/pakiti/pakiti-server-ca.pem';
# PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE_DEFAULT: see below how it is used
variable PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE_DEFAULT ?= 'features/pakiti/client/server-ca.pem';
variable PAKITI_CLIENT_SLEEP ?= 7200;
variable PAKITI_CLIENT_UPDATE_FREQ ?= "45 13 * * *";

# If PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE is not explicitely defined,
# its value is PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE_DEFAULT is the file exists
# else it remains undefined and PAKITI_SERVER_CERTIFICATION_CHAIN_FILE is not created
# If PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE is defined, the file referred to must exist.
variable PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE ?= {
    if ( file_exists(PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE_DEFAULT) ) {
        PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE_DEFAULT;
    } else {
        undef;
    };
};

# Build configuration file
include 'components/metaconfig/config';
include 'features/pakiti/client/config_schema';
prefix '/software/components/metaconfig/services/{/etc/pakiti/pakiti-client.conf}';
'backup' = '.old';
'module' = 'tiny';
'contents' = {
    SELF['site'] = PAKITI_TAG;
    SELF['url'] = format(
        "%s://%s:%s%s",
        PAKITI_SERVER_PROTOCOL,
        PAKITI_SERVER,
        PAKITI_SERVER_HTTP_PORT,
        PAKITI_SERVER_HTTP_FEED_URL,
    );
    if ( is_defined(PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE) ) {
        SELF['curl'] = format("curl --cacert %s", PAKITI_SERVER_CERTIFICATION_CHAIN_FILE);
    };
    # If PAKITI_SERVER_PUB_KEY_SOURCE is an existing file, define the encrypt
    # parameter. Else raise an error if the protocol is not https.
    if ( file_exists(PAKITI_SERVER_PUB_KEY_SOURCE) ) {
        SELF['encrypt'] = PAKITI_SERVER_PUB_KEY_FILE;
    } else if ( PAKITI_SERVER_PROTOCOL != 'https' ) {
        error('Pakiti server pub key is missing and feed protocol is not https');
    };
    SELF['rndsleep'] = PAKITI_CLIENT_SLEEP;
    SELF;
};
'convert/yesno' = true;
bind '/software/components/metaconfig/services/{/etc/pakiti/pakiti-client.conf}/contents' = pakiti_client_config;

# Generate server certificate and certification chain
include "components/filecopy/config";
"/software/components/filecopy/services" = {
    debug('Pakiti server certification chain source = %s', to_string(PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE));
    if ( is_defined(PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE) ) {
        SELF[escape(PAKITI_SERVER_CERTIFICATION_CHAIN_FILE)] =  dict(
            "config", file_contents(PAKITI_SERVER_CERTIFICATION_CHAIN_SOURCE),
            "perms", "0644",
        );
    };
    if ( file_exists(PAKITI_SERVER_PUB_KEY_SOURCE) ) {
        SELF[escape(PAKITI_SERVER_PUB_KEY_FILE)] = dict(
            "config", file_contents(PAKITI_SERVER_PUB_KEY_SOURCE),
            "perms", "0644",
        );
    };
    SELF;
};

# Add cron to run Pakiti client
include "components/cron/config";
"/software/components/cron/entries" = {
    SELF[length(SELF)] = dict(
        "name", "pakiti_update",
        "user", "root",
        "frequency", PAKITI_CLIENT_UPDATE_FREQ,
        "command", "/usr/bin/pakiti-client --conf /etc/pakiti/pakiti-client.conf",
    );
    SELF;
};
