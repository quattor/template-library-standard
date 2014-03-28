
unique template features/fetch-crl/config;

variable FETCH_CRL_QUIET ?= true;
variable FETCH_CRL_FORCE_OVERWRITE ?= true;

variable SITE_DEF_GRIDSEC_ROOT ?= "/etc/grid-security";
variable SITE_DEF_HOST_CERT    ?= SITE_DEF_GRIDSEC_ROOT+"/hostcert.pem";
variable SITE_DEF_HOST_KEY     ?= SITE_DEF_GRIDSEC_ROOT+"/hostkey.pem";
variable SITE_DEF_CERTDIR      ?= SITE_DEF_GRIDSEC_ROOT+"/certificates";

# Include RPMs
variable RPMS_CONFIG_SUFFIX ?= '';
include { 'features/fetch-crl/rpms' + RPMS_CONFIG_SUFFIX };

# Define fetch-crl version if not defined when adding RPMs
variable FETCH_CRL_VERSION ?= '3.0';

# ---------------------------------------------------------------------------- 
# fetch-crl configuration
# ---------------------------------------------------------------------------- 
include { 'components/sysconfig/config' };
"/software/components/sysconfig/files/fetch-crl/CRLDIR" = SITE_DEF_CERTDIR;
"/software/components/sysconfig/files/fetch-crl/FORCE_OVERWRITE" = if ( FETCH_CRL_FORCE_OVERWRITE ) {
                                                                     'yes';
                                                                   } else {
                                                                     'no';
                                                                   };
"/software/components/sysconfig/files/fetch-crl/QUIET" = if ( FETCH_CRL_QUIET ) {
                                                           'yes';
                                                         } else {
                                                           'no';
                                                         };

# ---------------------------------------------------------------------------- 
# cron
# ---------------------------------------------------------------------------- 
include { 'components/cron/config' };
"/software/components/cron/entries" = {
  if (FETCH_CRL_VERSION < '3.0') {
    cron_cmd = '/usr/sbin/fetch-crl  --no-check-certificate --loc '+SITE_DEF_CERTDIR+' -out '+SITE_DEF_CERTDIR+' -a 24 --quiet';
    append(nlist("name","fetch-crl-cron",
                 "user","root",
                 "frequency", "AUTO 3,9,15,21 * * *",
                 "command", cron_cmd,
          ));
  };

  if ( is_defined(SELF) ) {
    SELF;
  } else {
    null;
  };
};


# ---------------------------------------------------------------------------- 
# altlogrotate
# ---------------------------------------------------------------------------- 
include { 'components/altlogrotate/config' }; 
"/software/components/altlogrotate/entries" = {
  if (FETCH_CRL_VERSION < '3.0') {
    SELF['fetch-crl-cron'] =   nlist("pattern", "/var/log/fetch-crl-cron.ncm-cron.log",
                                     "compress", true,
                                     "missingok", true,
                                     "frequency", "monthly",
                                     "create", true,
                                     "ifempty", true,
                                     "rotate", 12,
                                    );
  };

  if ( is_defined(SELF) ) {
    SELF;
  } else {
    null;
  };
};


# ---------------------------------------------------------------------------- 
# chkconfig
# ---------------------------------------------------------------------------- 
"/software/components/chkconfig/service" = {
  if (FETCH_CRL_VERSION >= '3.0') {
    # Run fetch-crl on boot
    SELF[escape('fetch-crl-boot')] = nlist("on", "",
                                           "startstop", true);
  };

  # Enable periodic fetch-crl (cron)
  SELF[escape('fetch-crl-cron')] = nlist("on", "",
                                         "startstop", true);

  SELF;
};
