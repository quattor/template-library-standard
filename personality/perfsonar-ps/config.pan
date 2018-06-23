unique template personality/perfsonar-ps/config;

variable PERFSONAR_CONFIG_SCRIPT ?= '/var/quattor/scripts/perfsonar-postconfig.sh';

@{
desc = define the bwctl server configuration
value = string
}
variable PERFSONAR_BWCTL_CONF_FILE ?= '/etc/bwctld/bwctld.conf';

@{
desc = define the owamp server configuration
value = string
}
variable PERFSONAR_OWAMP_CONF_FILE ?= '/etc/owampd/owampd.conf';

# Install needed packages for perfsonar-ps
include 'personality/perfsonar-ps/rpms';
include 'repository/config/perfsonar-ps';

# Include EGI CA certificates and keep CRLs up to date
include 'security/cas';
include 'features/fetch-crl/config';

# perfSONAR ports
variable PERFSONAR_PORTS_DEFAULT ?= nlist(
    'BWCTL', nlist(
        'iperf_port', '5001:5200',
        'nuttcp_port', '5201:5600',
        'peer_port', '6001:6200',
        'test_port', '5001:5900',
        'owamp_port', '5601:5900',
    ),
    'OWAMP', nlist(
        'testports', '8760:9960',
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
    if ( !is_defined(SELF) || (index(item, SELF) == -1) ) {
        append(item);
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
sed -i 's|^#\?\s*peer_port\s\+[0-9].*|peer_port QUATTOR_PEER_PORT|' /etc/bwctld/bwctld.conf
if ! grep ^peer_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'peer_port QUATTOR_PEER_PORT' >> PERFSONAR_BWCTL_CONF_FILE
fi

#
# Configure tcp/udp iperf_port
#
sed -i 's|^#\?\s*iperf_port\s\+[0-9].*|iperf_port QUATTOR_IPERF_PORT|' /etc/bwctld/bwctld.conf
if ! grep ^iperf_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'iperf_port QUATTOR_IPERF_PORT' >> PERFSONAR_BWCTL_CONF_FILE
fi

#
# Configure tcp/udp nuttcp_port
#
sed -i 's|^#\?\s*nuttcp_port\s\+[0-9].*|nuttcp_port QUATTOR_NUTTCP_PORT|' /etc/bwctld/bwctld.conf
if ! grep ^nuttcp_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'nuttcp_port QUATTOR_NUTTCP_PORT' >> PERFSONAR_BWCTL_CONF_FILE
fi

#
# Configure tcp/udp owamp_port
#
sed -i 's|^#\?\s*owamp_port\s\+[0-9].*|owamp_port QUATTOR_OWAMP_PORT|' /etc/bwctld/bwctld.conf
if ! grep ^owamp_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'owamp_port QUATTOR_OWAMP_PORT' >> PERFSONAR_BWCTL_CONF_FILE
fi

#
# Configure tcp/udp test_port
#
sed -i 's|^#\?\s*test_port\s\+[0-9].*|test_port QUATTOR_TEST_PORT|' /etc/bwctld/bwctld.conf
if ! grep ^test_port /etc/bwctld/bwctld.conf > /dev/null 2>&1 ; then
    echo 'test_port QUATTOR_TEST_PORT' >> PERFSONAR_BWCTL_CONF_FILE
fi

#
# Configure tcp/udp testports
#
sed -i 's|^#\?\s*testports\s\+[0-9].*|testports QUATTOR_TESTPORTS|' /etc/owampd/owampd.conf
if ! grep ^testports /etc/owampd/owampd.conf > /dev/null 2>&1 ; then
    echo 'testports QUATTOR_TESTPORTS' >> PERFSONAR_OWAMP_CONF_FILE
fi
EOF

        this = replace('PERFSONAR_BWCTL_CONF_FILE', PERFSONAR_BWCTL_CONF_FILE, this);
        this = replace('PERFSONAR_OWAMP_CONF_FILE', PERFSONAR_OWAMP_CONF_FILE, this);

        this = replace('QUATTOR_PEER_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['peer_port']), this);
        this = replace('QUATTOR_IPERF_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['iperf_port']), this);
        this = replace('QUATTOR_NUTTCP_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['nuttcp_port']), this);
        this = replace('QUATTOR_OWAMP_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['owamp_port']), this);
        this = replace('QUATTOR_TEST_PORT', replace(':', '-', PERFSONAR_PORTS['BWCTL']['test_port']), this);
        this = replace('QUATTOR_TESTPORTS', replace(':', '-', PERFSONAR_PORTS['OWAMP']['testports']), this);
    };
    this;
};

#
# Install the script and set it to run if modified
#
include {'components/filecopy/config'};
'/software/components/filecopy/services' = {
  SELF[escape(PERFSONAR_CONFIG_SCRIPT)] = nlist('config', contents,
                                                'perms', '0755',
                                                'owner', 'root',
                                                'group', 'root',
                                                'backup', false,
                                                'restart', PERFSONAR_CONFIG_SCRIPT,
                                               );
  SELF;
};


