unique template features/cvmfs/rpms/client-0.2.71-1;

# CernVM-FS RPMs
'/software/packages' = pkg_repl('cvmfs', '0.2.71-1', PKG_ARCH_DEFAULT);
'/software/packages' = pkg_repl('cvmfs-init-scripts', '1.0.12-1', 'noarch');
'/software/packages' = pkg_repl('cvmfs-keys', '1.1-2', 'noarch');
