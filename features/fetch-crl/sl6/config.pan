unique template features/fetch-crl/sl6/config;

include "components/chkconfig/config";
"/software/components/chkconfig/service" = {
    # Run fetch-crl on boot
    SELF[escape('fetch-crl-boot')] = dict("on", "",
                                        "startstop", true);

    # Enable periodic fetch-crl (cron)
    SELF[escape('fetch-crl-cron')] = dict("on", "",
                                        "startstop", true);

    SELF;
};

