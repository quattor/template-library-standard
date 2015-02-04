unique template features/cvmfs/server;

#
# Configurable variables
#

# Repository contining the RPMs
variable CVMFS_RPM_REPOSITORIES ?= list('CernVM-FS');


#
# Add RPMs
#
include {'features/cvmfs/rpms/server'};

#
# Require httpd server
#
include { 'config/os/httpd' };

#
# Add repository
#
include {'quattor/functions/repository'};
'/software/repositories' = {
    if(is_list(CVMFS_RPM_REPOSITORIES)) {
        add_repositories(CVMFS_RPM_REPOSITORIES);
    };
    SELF;
};

