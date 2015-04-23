unique template features/pakiti/client/configv3;

variable PAKITI_RPMS ?= if_exists('config/pakiti/client/config');
variable PAKITI_RPMS ?= 'features/pakiti/client/rpms';
include { PAKITI_RPMS };

variable PAKITI_TAG ?= error('PAKITI_TAG is a mandatory variable');
variable PAKITI_SERVER ?=  error('PAKITI_SERVER is a mandatory variable');
variable PAKITI_SERVER_HTTP_PORT ?= 20080;
variable PAKITI_SERVER_HTTP_FEED_URL ?= '/feed-http/';
variable PAKITI_SERVER_PUB_KEY ?= error('PAKITI_SERVER_PUB_KEY is a mandatory variable');
variable PAKITI_CLIENT_SLEEP ?= '7200';
variable PAKITI_CLIENT_CONF ?= '/etc/pakiti/pakiti-client.conf';
variable PAKITI_CLIENT_UPDATE_FREQ ?= "45 13 * * *";

variable pakiti_conf = format("site = %s\n", PAKITI_TAG);
variable pakiti_conf = pakiti_conf + format("url = http://%s:%s%s\n", PAKITI_SERVER, PAKITI_SERVER_HTTP_PORT, PAKITI_SERVER_HTTP_FEED_URL);
variable pakiti_conf = pakiti_conf + "expect = 200 OK\n";
variable pakiti_conf = pakiti_conf + "encrypt = <<EOT\n"+ PAKITI_SERVER_PUB_KEY + "EOT\n";
variable pakiti_conf = pakiti_conf + format("rndsleep = %s\n",PAKITI_CLIENT_SLEEP);


include { "components/filecopy/config" };
"/software/components/filecopy/services" = npush(
    escape(PAKITI_CLIENT_CONF), nlist(
        "config",pakiti_conf,
        "perms","0644",
    ),
);

include {"components/cron/config"};
"/software/components/cron/entries" =
  push(nlist(
    "name","pakiti_update",
    "user","root",
    "frequency", PAKITI_CLIENT_UPDATE_FREQ,
    'command', '/usr/bin/pakiti-client --conf '+PAKITI_CLIENT_CONF));
