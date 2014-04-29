unique template features/pakiti/client/config;

variable PAKITI_RPMS ?= if_exists('config/pakiti/client/config');
variable PAKITI_RPMS ?= 'features/pakiti/client/rpms';
include { PAKITI_RPMS };

variable pakiti_conf = "servers_name = "+PAKITI_SERVER+":"+PAKITI_SERVER_PORT+"\n";
variable pakiti_conf = pakiti_conf+"server_url = "+PAKITI_SERVER_URL+"\n";
variable pakiti_conf = pakiti_conf+"ca_certificate = "+PAKITI_CA_PATH+"\n";
variable pakiti_conf = pakiti_conf+"tag = "+PAKITI_TAG+"\n";

variable PAKITI_CLIENT_INSECURE ?= false;
variable PAKITI_CLIENT_CONF ?= '/etc/pakiti2/pakiti2-client.conf';
variable pakiti_conf = if (is_boolean(PAKITI_CLIENT_INSECURE) && PAKITI_CLIENT_INSECURE ) {
  SELF + "curl_path = /usr/bin/curl --insecure\n"; } else SELF;

include { "components/filecopy/config" };
"/software/components/filecopy/services" = npush(
    escape(PAKITI_CLIENT_CONF), nlist(
        "config",pakiti_conf,
        "perms","0644",
    ),
);
