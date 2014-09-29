unique template features/pakiti/client/config;

variable PAKITI_RPMS ?= if_exists('config/pakiti/client/config');
variable PAKITI_RPMS ?= 'features/pakiti/client/rpms';
include { PAKITI_RPMS };

# Variables are checked in main config template

variable pakiti_conf = format("servers_name = %s:%d\n", PAKITI_SERVER, PAKITI_SERVER_PORT);
variable pakiti_conf = pakiti_conf + format("server_url = %s\n", PAKITI_SERVER_FEED_URL);
variable pakiti_conf = pakiti_conf + format("ca_certificate = %s\n", PAKITI_CA_PATH);
variable pakiti_conf = pakiti_conf + format("tag = %s\n", PAKITI_TAG);

variable PAKITI_CLIENT_INSECURE ?= false;
variable PAKITI_CLIENT_CONF ?= '/etc/pakiti2/pakiti2-client.conf';
variable pakiti_conf = if (is_boolean(PAKITI_CLIENT_INSECURE) && PAKITI_CLIENT_INSECURE ) {
                         SELF + "curl_path = /usr/bin/curl --insecure\n"; 
                       } else {
                         SELF;
                       };

include { "components/filecopy/config" };
"/software/components/filecopy/services" = npush(
    escape(PAKITI_CLIENT_CONF), nlist(
        "config",pakiti_conf,
        "perms","0644",
    ),
);
