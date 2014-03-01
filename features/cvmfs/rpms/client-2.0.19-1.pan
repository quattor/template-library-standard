unique template features/cvmfs/rpms/client-2.0.19-1;

# CernVM-FS RPMs
variable elx ?= '5';
'/software/packages' = pkg_repl('cvmfs', '2.0.19-1.el' + elx, PKG_ARCH_DEFAULT);
'/software/packages' = pkg_repl('cvmfs-init-scripts', '1.0.18-2', 'noarch');
'/software/packages' = pkg_repl('cvmfs-keys', '1.4-1', 'noarch');
