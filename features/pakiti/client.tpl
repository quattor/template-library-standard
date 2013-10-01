unique template features/pakiti/client;

include { 'config/pakiti/client/config' };

variable pakiti_conf = "servers_name = "+PAKITI_SERVER+":"+PAKITI_SERVER_PORT+"\n";
variable pakiti_conf = pakiti_conf+"server_url = "+PAKITI_SERVER_URL+"\n";
variable pakiti_conf = pakiti_conf+"ca_certificate = "+PAKITI_CA_PATH+"\n";
variable pakiti_conf = pakiti_conf+"tag = "+PAKITI_TAG+"\n";

variable PAKITI_CLIENT_INSECURE ?= false;
variable pakiti_conf = if (is_boolean(PAKITI_CLIENT_INSECURE) && PAKITI_CLIENT_INSECURE ) {
  SELF + "curl_path = /usr/bin/curl --insecure\n"; } else SELF;

include { "components/filecopy/config" };
"/software/components/filecopy/services" =
 npush(escape("/etc/pakiti2/pakiti2-client.conf"),
       nlist("config",pakiti_conf,
             "perms","0644"));
