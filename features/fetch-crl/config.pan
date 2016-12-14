
unique template features/fetch-crl/config;

variable FETCH_CRL_QUIET ?= true;
variable FETCH_CRL_FORCE_OVERWRITE ?= true;
# This avoid having fetch-crl-boot return a non-zero exit status on
# transient errors. Does not apply to the cron.
# Ignored (but harmless) if fetch-crl < 3.0.13.
variable FETCH_CRL_BOOT_IGNORE_RETRIEVAL_ERRORS ?= true;

variable SITE_DEF_GRIDSEC_ROOT ?= "/etc/grid-security";
variable SITE_DEF_HOST_CERT    ?= SITE_DEF_GRIDSEC_ROOT+"/hostcert.pem";
variable SITE_DEF_HOST_KEY     ?= SITE_DEF_GRIDSEC_ROOT+"/hostkey.pem";
variable SITE_DEF_CERTDIR      ?= SITE_DEF_GRIDSEC_ROOT+"/certificates";

# Include RPMs
variable RPMS_CONFIG_SUFFIX ?= '';
include 'features/fetch-crl/rpms' + RPMS_CONFIG_SUFFIX;

# Define fetch-crl version if not defined when adding RPMs
variable FETCH_CRL_VERSION ?= '3.0';

# ----------------------------------------------------------------------------
# fetch-crl configuration
# ----------------------------------------------------------------------------
include 'components/metaconfig/config';
include 'features/fetch-crl/schema';
include 'quattor/functions/package';
# property 'daemons' and 'convert/yesno' are not supported prior to version 16.6. Additionally,
# in version of metaconfig before 15.12, metaconfig doesn't publish its version.
# Exit with an error if an older version is used.
prefix '/software/components/metaconfig/services/{/etc/sysconfig/fetch-crl}';
variable CHECK_VERSION = if ( !exists('/software/components/metaconfig/version') ||
                              (pkg_compare_version(value('/software/components/metaconfig/version'), '16.6.0') == PKG_VERSION_LESS ) ) {
                           error('fetch-crl configuration requires ncm-metaconfig version >= 16.6.0');
                         };
'backup' = '.old';
'daemons' =  dict('fetch-crl-boot', 'restart');
'module' = 'tiny';
'contents' = {
  SELF["CRLDIR"] = SITE_DEF_CERTDIR;
  if ( FETCH_CRL_BOOT_IGNORE_RETRIEVAL_ERRORS ) {
    SELF["FETCHCRL_BOOT_OPTIONS"] = '"--define rcmode=noretrievalerrors"';
  };
  SELF["FORCE_OVERWRITE"] = FETCH_CRL_FORCE_OVERWRITE;
  SELF["QUIET"] = FETCH_CRL_QUIET;
  SELF;
};
'convert/yesno' = true;
bind '/software/components/metaconfig/services/{/etc/sysconfig/fetch-crl}/contents' = fetch_crl_sysconfig_keys;


# ----------------------------------------------------------------------------
# cron
# ----------------------------------------------------------------------------
include 'components/cron/config';
"/software/components/cron/entries" = {
  if (FETCH_CRL_VERSION < '3.0') {
    cron_cmd = '/usr/sbin/fetch-crl  --no-check-certificate --loc '+SITE_DEF_CERTDIR+' -out '+SITE_DEF_CERTDIR+' -a 24 --quiet';
    append(dict("name","fetch-crl-cron",
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
include 'components/altlogrotate/config';
"/software/components/altlogrotate/entries" = {
  if (FETCH_CRL_VERSION < '3.0') {
    SELF['fetch-crl-cron'] =   dict("pattern", "/var/log/fetch-crl-cron.ncm-cron.log",
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
    SELF[escape('fetch-crl-boot')] = dict("on", "",
                                          "startstop", true);
  };

  # Enable periodic fetch-crl (cron)
  SELF[escape('fetch-crl-cron')] = dict("on", "",
                                        "startstop", true);

  SELF;
};
