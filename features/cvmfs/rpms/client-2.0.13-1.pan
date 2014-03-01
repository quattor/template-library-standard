unique template features/cvmfs/rpms/client-2.0.13-1;

# CernVM-FS RPMs
variable elx ?= '5';
'/software/packages' = pkg_repl('cvmfs', '2.0.13-1.el' + elx, PKG_ARCH_DEFAULT);
'/software/packages' = pkg_repl('cvmfs-init-scripts', '1.0.15-1', 'noarch');
'/software/packages' = pkg_repl('cvmfs-keys', '1.2-1', 'noarch');
