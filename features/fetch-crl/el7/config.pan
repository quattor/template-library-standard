
unique template features/fetch-crl/el7/config;


include 'components/systemd/config';

'/software/components/systemd/skip/service' = false;

# This is a customization file
'/software/components/systemd/unit/fetch-crl-boot/file/replace' = false;

# Fix for issue https://bugzilla.redhat.com/show_bug.cgi?id=1630027
prefix '/software/components/systemd/unit/fetch-crl-boot/file/config/service';
'RemainAfterExit' = true;

# Enable fetch-crl CRON
prefix '/software/components/systemd/unit/fetch-crl-cron';
'state' = 'enabled';
