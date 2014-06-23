unique template personality/perfsonar-ps/config;

# RPMs
include { 'personality/perfsonar-ps/rpms/config' };
include { 'repository/config/perfsonar-ps' };

# Include EGI CA certificates and keep CRLs up to date
include {'security/cas'};
include {'features/fetch-crl/config'};

# perfSONAR ports
variable PERFSONAR_PORTS_DEFAULT ?= nlist(
    'BWCTL', nlist(
        'iperf_port', '5001:5200',
        'nuttcp_port', '5201:5600',
        'peer_port', '6001:6200',
    ),
    'OWAMP', nlist(
        'testports', '8760:8960',
    ),
);

@{
desc = port ranges to use for perfSonar defined as nlist
values = nlist whose keys are BWCTL (throughput tests) and OWAMP (latency tests)\
 and values are nlist of port ranges (see source). Every omitted value will take the \
 default value.
default = PERFSONAR_PORTS_DEFAULT
required = no
}
variable PERFSONAR_PORTS = {
  foreach (component;port_list;PERFSONAR_PORTS_DEFAULT) {
    foreach (range_name;range_ports;port_list) {
      if ( !is_defined(SELF[component][range_name]) ) {
        if ( !is_defined(SELF[component]) ) {
          SELF[component] = nlist();
        };
        SELF[component][range_name] = range_ports;
      };
    };
  };
  SELF;
};

#
# Make sure that the wheel group can use sudo
#
include {'components/sudo/config'};
'/software/components/sudo/privilege_lines' = {
    item = nlist('user', '%wheel', 'run_as', 'ALL', 'host', 'ALL', 'cmd', 'ALL');
    if (is_defined(SELF)) {
        if (index(item, SELF) == -1) {
            append(item);
        };
    };
    SELF;
};

#
# Postconfigure script
#
variable contents = {
    this = '!#/bin/bash\n\n';
    if (is_defined(PERFSONAR_PORTS)) {
        this = <<EOF;

#
# Configure tcp/udp peer_port
#
if ! grep ^peer_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    sed -i 's|^#peer_port.*$|peer_port QUATTOR_PEER_PORT|' /etc/bwctld/bwctld.conf
else
    sed -i 's|^peer_port.*$|peer_port QUATTOR_PEER_PORT|' /etc/bwctld/bwctld.conf
fi
if ! grep ^peer_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'peer_port QUATTOR_PEER_PORT' >> /etc/bwctld/bwctld.conf
fi

#
# Configure tcp/udp iperf_port
#
if ! grep ^iperf_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    sed -i 's|^#iperf_port.*$|iperf_port QUATTOR_IPERF_PORT|' /etc/bwctld/bwctld.conf
else
    sed -i 's|^iperf_port.*$|iperf_port QUATTOR_IPERF_PORT|' /etc/bwctld/bwctld.conf
fi
if ! grep ^iperf_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'iperf_port QUATTOR_IPERF_PORT' >> /etc/bwctld/bwctld.conf
fi

#
# Configure tcp/udp nuttcp_port
#
if ! grep ^nuttcp_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    sed -i 's|^#nuttcp_port.*$|nuttcp_port QUATTOR_NUTTCP_PORT|' /etc/bwctld/bwctld.conf
else
    sed -i 's|^nuttcp_port.*$|nuttcp_port QUATTOR_NUTTCP_PORT|' /etc/bwctld/bwctld.conf
fi
if ! grep ^nuttcp_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'nuttcp_port QUATTOR_NUTTCP_PORT' >> /etc/bwctld/bwctld.conf
fi

#
# Configure tcp/udp testports
#
if ! grep ^testports /etc/owampd/owampd.conf > /dev/null 2>&1 ; then
    sed -i 's|^#testports.*$|testports QUATTOR_TESTPORTS|' /etc/owampd/owampd.conf
else
    sed -i 's|^testports.*$|testports QUATTOR_TESTPORTS|' /etc/owampd/owampd.conf
fi
if ! grep ^testports /etc/owampd/owampd.conf > /dev/null 2>&1 ; then
    echo 'testports QUATTOR_TESTPORTS' >> /etc/owampd/owampd.conf
fi
EOF
        this = replace('QUATTOR_PEER_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['peer_port']), this);
        this = replace('QUATTOR_IPERF_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['iperf_port']), this);
        this = replace('QUATTOR_NUTTCP_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['nuttcp_port']), this);
        this = replace('QUATTOR_TESTPORTS', replace(':', '-', PERFSONAR_PORTS['OWAMP']['testports']), this);
    };
    this;
};

#
# Install the script and set it to run if modified
#
include {'components/filecopy/config'};
'/software/components/filecopy/services/{/usr/local/sbin/perfsonar-postconfig.sh}' = nlist(
    'config', contents,
    'perms', '0755',
    'owner', 'root',
    'group', 'root',
    'backup', false,
    'restart', '/usr/local/sbin/perfsonar-postconfig.sh',
);
