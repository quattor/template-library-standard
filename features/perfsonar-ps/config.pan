# This templates is based on reference-platform.ks used by standard NetInstall for 
# perfSONAR-PS. Standard configuration modules are used as much as possible but
# some actions are implemented in a script installed by filecopy (configured
# by postconfig.tpl).

unique template features/perfsonar-ps/config;

variable PERFSONAR_USER ?= 'perfsonar';
variable PERFSONAR_GROUP ?= 'perfsonar';
variable PERFSONAR_OWAMP_BWCTL_LOG ?= '/var/log/perfsonar/owamp_bwctl.log';

# Add RPMs
include { 'features/perfsonar-ps/rpms/config' };

include { 'components/sysctl/config' };
include { 'components/chkconfig/config' };
include { 'components/altlogrotate/config' };


# ----------------------------------------------------------------------------
# Stop unwanted services
# ----------------------------------------------------------------------------

variable PERSFSONAR_UNWANTED_SERVICES ?= list('cups',
                                              'gpm',
                                              'portmap',
                                              'iptables',
                                              'ip6tables',
                                              'irqbalance',
                                              'bluetooth',
                                              'haldaemon',
                                              'cpuspeed',
                                              'pcscd',
                                              'nfslock',
                                              'ypbind',
                                              'mdmonitor',
                                              'rpcidmapd',
                                              'rpcgssd',
                                              'netfs',
                                              'autofs',
                                              'yum-updatesd',
                                              'avahi-dnsconfd',
                                              'psacct',
                                              'nfs',
                                              'irda',
                                              'rpcsvcgssd',
                                              'mdmpd',
                                              'readahead_later',
                                              'readahead_early',
                                              'kudzu',
                                              'apmd',
                                              'hidd',
                                              'avahi-daemon',
                                              'firstboot',
                                              'smartd',
                                             );


'/software/components/chkconfig/service' = {
  foreach (i;service;PERSFSONAR_UNWANTED_SERVICES) {
    SELF[service] = nlist('off', '',
                          'startstop', true,
                         );
  };
  SELF;
};


# ----------------------------------------------------------------------------
# Stop unwanted services
# ----------------------------------------------------------------------------

variable PERSFSONAR_WANTED_SERVICES ?= list('sshd',
                                           );


'/software/components/chkconfig/service' = {
  foreach (i;service;PERSFSONAR_WANTED_SERVICES) {
    SELF[service] = nlist('on', '',
                          'startstop', true,
                         );
  };
  SELF;
};


# ----------------------------------------------------------------------------
# Better tune the TCP defaults
# ----------------------------------------------------------------------------

prefix '/software/components/sysctl/variables';

# increase TCP max buffer size setable using setsockopt()
# 16 MB with a few parallel streams is recommended for most 10G paths
# 32 MB might be needed for some very long end-to-end 10G or 40G paths
'net.core.rmem_max' = '33554432';
'net.core.wmem_max' = '33554432';
# increase Linux autotuning TCP buffer limits
# min, default, and max number of bytes to use
# (only change the 3rd value, and make it 16 MB or more)
'net.ipv4.tcp_rmem' = '4096 87380 16777216';
'net.ipv4.tcp_wmem' = '4096 65536 16777216';
# recommended to increase this for 10G NICS
'net.core.netdev_max_backlog' = '30000';
# don't cache ssthresh from previous connection
'net.ipv4.tcp_no_metrics_save' = '1';
# Explicitly set htcp as the congestion control
'net.ipv4.tcp_congestion_control' = 'htcp';


# ----------------------------------------------------------------------------
# altlogrotate
# ----------------------------------------------------------------------------

variable CONTENTS = <<EOF;
/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
/bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
EOF

"/software/components/altlogrotate/entries/owamp-logs" =
  nlist("pattern", PERFSONAR_OWAMP_BWCTL_LOG,
        "compress", true,
        "missingok", true,
        "frequency", "weekly",
        "create", true,
        "ifempty", true,
        "rotate", 1,
        "sharedscripts", true,
        "scripts", nlist('postrotate', CONTENTS),
        "createparams", nlist('owner',PERFSONAR_USER,
                              'group',PERFSONAR_GROUP,
                              'mode', '0644'),
       );



# ----------------------------------------------------------------------------
# Install a few login scripts to add required path
# ----------------------------------------------------------------------------

variable PERFSONAR_PATHMUNGE_CONTENTS = <<EOF;
pathmunge () {
        if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH=$PATH:$1
           else
              PATH=$1:$PATH
           fi
        fi
}

EOF

variable PERFSONAR_LOGIN_SCRIPTS = nlist(escape('/etc/profile.d/add_dbxml_dir.sh'), list('/usr/dbxml-2.3.11/bin'),
                                         escape('/etc/profile.d/add_toolkit_dirs.sh'), list('/opt/perfsonar_ps/toolkit/scripts'),
                                         escape('/etc/profile.d/add_sbin_dirs.sh'), list('/sbin','/usr/sbin','/usr/local/sbin'),
                                        );

'/software/components/filecopy/services' = {
  foreach (script;pathlist;PERFSONAR_LOGIN_SCRIPTS) {
    contents = PERFSONAR_PATHMUNGE_CONTENTS;
    foreach (i;path;pathlist) {
      contents = contents + 'pathmunge "' + path + '"' + "\n";
    };
    SELF[escape(script)] = nlist('config', contents,
                                 'perms', '0644',
                                 'owner', 'root'
                                );
  };
  SELF;
};


# ----------------------------------------------------------------------------
# Disable the HTTP TRACE methods
# ----------------------------------------------------------------------------

variable CONTENTS = <<EOF;
# Disables the HTTP TRACE method
TraceEnable      Off
EOF


'/software/components/filecopy/services' = {
  SELF[escape('/etc/httpd/conf.d/disable_trace.conf')] = nlist('config', CONTENTS);
  SELF;
};


# ----------------------------------------------------------------------------
# Hack: use a script for all the actions difficult to implement with 
# Quattor configuration modules
# ----------------------------------------------------------------------------
variable PERFSONAR_POST_CONFIG ?= 'features/perfsonar-ps/postconfig';
include { if_exists(PERFSONAR_POST_CONFIG) };


# ----------------------------------------------------------------------------
# perfSONAR-PS Mesh Configuration service
# ----------------------------------------------------------------------------
variable PERFSONAR_MESH_ENABLED ?= true;
include { if (is_boolean(PERFSONAR_MESH_ENABLED) && PERFSONAR_MESH_ENABLED) 'features/perfsonar-ps/mesh'};
