
unique template features/fetch-crl/el8/config;

include 'components/systemd/config';
'/software/components/systemd/unit/fetch-crl.timer/startstop' = true;
'/software/components/systemd/unit/fetch-crl.timer/type' = 'timer';

