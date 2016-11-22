unique template features/cvmfs/rpms;

'/software/packages/{cvmfs}' ?= dict();

include 'quattor/functions/package';

'/software/packages' = {
  if ((pkg_compare_version(CVMFS_CLIENT_VERSION, '2.1.20') == PKG_VERSION_LESS) || (OS_VERSION_PARAMS['major'] == 'sl5')) {
    SELF[escape('cvmfs-keys')] = dict();
  } else {
    SELF[escape('cvmfs-config-default')] = dict();
  };
  SELF;
};
