unique template features/cvmfs/config;

variable CVMFS_CLIENT_ENABLED ?= false;
include { 
    if ((is_boolean(CVMFS_CLIENT_ENABLED) && CVMFS_CLIENT_ENABLED)) {
        'features/cvmfs/client';
    };
};
