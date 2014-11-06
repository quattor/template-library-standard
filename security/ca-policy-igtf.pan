# Use only on machines managed by SPMA

unique template security/ca-policy-igtf;

'/software/packages' = pkg_repl('ca_policy_igtf-classic','1.58-1','noarch');
'/software/packages' = pkg_repl('ca_policy_igtf-mics',   '1.58-1','noarch');
'/software/packages' = pkg_repl('ca_policy_igtf-slcs',   '1.58-1','noarch');

