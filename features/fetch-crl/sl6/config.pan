unique template features/fetch-crl/sl6/config;

include "components/chkconfig/config";
"/software/components/chkconfig/service/{fetch-crl-boot}" = dict(
    "on", "",
    "startstop", true,
);

"/software/components/chkconfig/service/{fetch-crl-cron}" = dict(
    "on", "",
    "startstop", true,
);
