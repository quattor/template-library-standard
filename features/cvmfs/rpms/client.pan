unique template features/cvmfs/rpms/client;

# EL5, EL6 ... elx
variable elx = {
    if (is_defined(OS_VERSION_PARAMS['majorversion'])) {
        OS_VERSION_PARAMS['majorversion'];
    } else {
        '5'; # EL5 = current best guess
    };
};

# CernVM-FS RPMs
include {'features/cvmfs/rpms/client-' + CVMFS_CLIENT_VERSION };

# Additional RPMs from OS, may be disabled with 'null' value
variable CVMFS_OS_DEPS ?= 'config/cvmfs/client';
include { if_exists(to_string(CVMFS_OS_DEPS)) };
