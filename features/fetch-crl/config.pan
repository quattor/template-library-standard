
unique template features/fetch-crl/config;

variable FETCH_CRL_QUIET ?= true;
variable FETCH_CRL_FORCE_OVERWRITE ?= true;

variable SITE_DEF_GRIDSEC_ROOT ?= "/etc/grid-security";
variable SITE_DEF_HOST_CERT    ?= SITE_DEF_GRIDSEC_ROOT+"/hostcert.pem";
variable SITE_DEF_HOST_KEY     ?= SITE_DEF_GRIDSEC_ROOT+"/hostkey.pem";
variable SITE_DEF_CERTDIR      ?= SITE_DEF_GRIDSEC_ROOT+"/certificates";

# Include RPMs
variable RPMS_SUFFIX ?= '';
include { 'features/fetch-crl/rpms' + RPMS_SUFFIX };

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
variable FETCH_CRL_VERSION ?= '2.0.7-2';
variable FETCH_CRL_CRON_COMMAND ?= {
    if (FETCH_CRL_VERSION >= '3.0') {
        '[ ! -f /var/lock/subsys/fetch-crl-cron ] || ( [ -f /etc/sysconfig/fetch-crl ] && . /etc/sysconfig/fetch-crl ; /usr/sbin/fetch-crl -q -r 360 )';
    } else {
        '/usr/sbin/fetch-crl  --no-check-certificate --loc '+SITE_DEF_CERTDIR+' -out '+SITE_DEF_CERTDIR+' -a 24 --quiet';
    };
};
include { 'components/cron/config' };
"/software/components/cron/entries" = push(nlist(
    "name","fetch-crl-cron",
    "user","root",
    "frequency", "AUTO 3,9,15,21 * * *",
    "command", FETCH_CRL_CRON_COMMAND,
));


# ---------------------------------------------------------------------------- 
# altlogrotate
# ---------------------------------------------------------------------------- 
include { 'components/altlogrotate/config' }; 
"/software/components/altlogrotate/entries/fetch-crl-cron" = 
  nlist("pattern", "/var/log/fetch-crl-cron.ncm-cron.log",
        "compress", true,
        "missingok", true,
        "frequency", "monthly",
        "create", true,
        "ifempty", true,
        "rotate", 12);

# --
# spam
# --
"/software/components/chkconfig/service/{fetch-crl-cron}/on" = "";            
"/software/components/chkconfig/service/{fetch-crl-cron}/startstop" = true;
