unique template features/cvmfs/config;

variable CVMFS_CLIENT_ENABLED ?= false;
include if ( CVMFS_CLIENT_ENABLED ) 'features/cvmfs/client';
