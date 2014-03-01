unique template security/ca-policy-egi-core-yd;

'/software/packages/{ca-policy-egi-core}' ?= nlist();
'/software/packages' = pkg_repl('dummy-ca-certs','20090630-1','noarch');
