unique template features/cvmfs/rpms;

'/software/packages/{cvmfs}' ?= dict();

include 'quattor/functions/package';

'/software/packages' = {
  if ((pkg_compare_version(CVMFS_CLIENT_VERSION, '2.1.20') >= 0) && (OS_VERSION_PARAMS['major'] != 'sl5')) {
    SELF[escape('cvmfs-config-default')] = dict();
  } else {
    SELF[escape('cvmfs-keys')] = dict();
  };
  SELF;
};
