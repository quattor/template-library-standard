unique template features/perfsonar-ps/rpms/mesh;

'/software/packages' = pkg_repl('perl-Algorithm-C3', '0.06-1.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Class-C3', '0.19-2.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Class-C3-XS', '0.08-1.el5', PKG_ARCH_DEFAULT);
'/software/packages' = pkg_repl('perl-Class-MOP', '0.62-1.el5', PKG_ARCH_DEFAULT);
'/software/packages' = pkg_repl('perl-Data-OptList', '0.101-2.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Moose', '0.51-1.el5', 'noarch');
'/software/packages' = pkg_repl('perl-MRO-Compat', '0.09-1.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Package-Generator', '0.100-2.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Params-Util', '1.00-3.el5', PKG_ARCH_DEFAULT);
'/software/packages' = pkg_repl('perl-perfSONAR_PS-MeshConfig-Agent', '3.2.2-9.pSPS', 'noarch');
'/software/packages' = pkg_repl('perl-perfSONAR_PS-MeshConfig-Shared', '3.2.2-9.pSPS', 'noarch');
'/software/packages' = pkg_repl('perl-Sub-Exporter', '0.982-11.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Sub-Identify', '0.03-1.el5', 'noarch');
'/software/packages' = pkg_repl('perl-Sub-Install', '0.925-1.el5', 'noarch');

# Include EPEL
include { 'quattor/functions/repository' };
