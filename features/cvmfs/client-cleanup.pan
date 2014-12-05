unique template features/cvmfs/client-cleanup;

#
# Configurable variables
#

# Do cleanup if quota exeeded, defaults to twice the RAM size
variable CVMFS_CLIENT_CLEANUP_QUOTA ?= undef;

# Do cleanup if disk space is below threshold, defaults to 1024M
variable CVMFS_CLIENT_CLEANUP_THRESHOLD ?= 1024;

# Target size per repository to try to get down to, defaults to 256M
variable CVMFS_CLIENT_CLEANUP_TARGET ?= 256;

# When to check, cron frecuency, defaults to once per hour
variable CVMFS_CLIENT_CLEANUP_CRON_FRECUENCY ?= '42 * * * *';

# Randomly delay startup time, defaults 0 to 1799 seconds
variable CVMFS_CLIENT_CLEANUP_CRON_SLEEP ?= 1800;

# Quattor scripts directory
variable QUATTOR_SCRIPTS_LOCATION ?= '/usr/local/sbin';

# Script name
variable CVMFS_CLIENT_CLEANUP_SCRIPT ?= QUATTOR_SCRIPTS_LOCATION + '/cvmfs_client_cleanup.sh';

# Script template
variable CVMFS_CLIENT_CLEANUP_SCRIPT_TEMPLATE ?= 'features/cvmfs/script/cvmfs_client_cleanup.sh';

#
# cleanup script
#
include {'components/filecopy/config'};
'/software/components/filecopy/services' = {
    SELF[escape(CVMFS_CLIENT_CLEANUP_SCRIPT)] = nlist(
        'config', file_contents(CVMFS_CLIENT_CLEANUP_SCRIPT_TEMPLATE),
        'owner', 'root',
        'perms', '0744',
        'backup', false,
    );
    SELF;
};


#
# set quota to twice the RAM, if not previously defined
#
variable CVMFS_CLIENT_CLEANUP_QUOTA ?= {
    ram = 0;
    foreach(k; v; value('/hardware/ram')) {
        ram = ram + v['size'] * 2;
    };
    ram;
};


#
# cron job
#
variable cron_command = {
    this = 'sleep $[ $RANDOM \% ' + to_string(CVMFS_CLIENT_CLEANUP_CRON_SLEEP) + ' ]s;'
        + 'flock -n /var/lock/cvmfs_client_cleanup.lock '
        + CVMFS_CLIENT_CLEANUP_SCRIPT + ' '
        + to_string(CVMFS_CLIENT_CLEANUP_QUOTA) + ' '
        + to_string(CVMFS_CLIENT_CLEANUP_THRESHOLD) + ' '
        + to_string(CVMFS_CLIENT_CLEANUP_TARGET);
    if (is_string(CVMFS_CACHE_BASE)) {
        this = this + ' ' + CVMFS_CACHE_BASE;
    };
    this;
};
include { 'components/cron/config' };
'/software/components/cron/entries' = append(nlist(
    'name', 'cvmfs-client-cleanup',
    'user', 'root',
    'frequency', CVMFS_CLIENT_CLEANUP_CRON_FRECUENCY,
    'command', cron_command,
));
