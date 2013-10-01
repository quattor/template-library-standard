unique template features/hepixvmilsubscriber/rpms;

'/software/packages' = pkg_repl('hepixvmilsubscriber','0.1.13-1','noarch');
'/software/packages' = pkg_repl('hepixvmitrust','0.0.14-1','noarch');
'/software/packages' = pkg_repl('smimeX509validation','0.0.8-1','noarch');

include { 'config/misc/hepixvmilsubscriber' };
