unique template personality/perfsonar-ps/rpms/config;

'/software/packages' = {
# perfSonar and related mandatory tools
  pkg_repl('iperf3');
  pkg_repl('kmod-sk98lin');
  pkg_repl('nuttcp');
  pkg_repl('perl-DBD-mysql');
  pkg_repl('perl-DBI');
  pkg_repl('perl-perfSONAR_PS-Toolkit');
  pkg_repl('perl-perfSONAR_PS-MeshConfig-Agent');
  pkg_repl('policycoreutils');
  pkg_repl('system-config-firewall-base');
  pkg_repl('tcpdump');
  pkg_repl('tcptrace');
  pkg_repl('web100_userland');
  pkg_repl('xplot-tcptrace');

  # Useful additional packages
  pkg_repl('nc');

  SELF;
};
