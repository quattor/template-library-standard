unique template features/podman/api_daemon;

variable PODMAN_SERVICE ?= if ( OS_VERSION_PARAMS['majorversion'] >= '8' ) {
    'podman';
} else {
    'io.podman';
};

include 'components/systemd/config';

'/software/components/systemd/skip/service' = false;

'/software/components/systemd/unit' = {
    SELF[PODMAN_SERVICE]['file']['replace'] = false;
    SELF[PODMAN_SERVICE]['file']['config']['service'] = dict('EnvironmentFile', list('/etc/sysconfig/podman'));
    SELF[PODMAN_SERVICE]['startstop'] = true;
    SELF[PODMAN_SERVICE]['state'] = 'enabled';
    SELF;
};

