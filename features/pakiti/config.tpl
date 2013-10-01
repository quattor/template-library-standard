unique template features/pakiti/config;

variable SITE_DEF_CERTDIR ?= '/etc/grid-security/certificates';

variable PAKITI_SERVER ?= undef;
variable PAKITI_SERVER_PORT ?= "443";
variable PAKITI_SERVER_URL ?= "/feed/";
variable PAKITI_CA_PATH ?= SITE_DEF_CERTDIR;
variable PAKITI_TAG ?= "DEFAULT_QWG_TAG";

variable PAKITI_TITLE ?= "Quattor Pakiti instance";

variable PAKITI_DB_NAME ?= 'pakiti';
variable PAKITI_DB_HOST ?= 'localhost';
variable PAKITI_DB_USER ?= 'pakiti';
variable PAKITI_DB_PASS ?= 'pakiti';

include { 'security/cas' };
include { 'features/fetch-crl/config' };

include { if ( PAKITI_SERVER == FULL_HOSTNAME ) {
	'features/pakiti/server';
} else {
	'features/pakiti/client';
};

};

# updates
include {'features/pakiti/updates'};
