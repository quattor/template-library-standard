
unique template features/fetch-crl/el7/config;


include 'components/systemd/config';

'/software/components/systemd/skip/service' = false;

##################
# fetch-crl-boot #
##################

prefix '/software/components/systemd/unit/fetch-crl-boot';

# Fix for issue https://bugzilla.redhat.com/show_bug.cgi?id=1630027
# Create a customization file
'file/replace' = false;
'file/config/service/RemainAfterExit' = true;


##################
# fetch-crl-cron #
##################

# Enable fetch-crl-cron
prefix '/software/components/systemd/unit/fetch-crl-cron';
'state' = 'enabled';
