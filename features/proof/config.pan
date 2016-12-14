# Configure a PROOF cluster.
# Root must be installed indepedently, preferably in a shared area, as
# there is no Root RPM.

unique template features/proof/config;

variable PROOF_CONFIG_SITE ?= null;

variable PROOF_SERVICE ?= 'xrootd';
variable PROOF_STARTUP_SCRIPT ?= '/etc/init.d/' + PROOF_SERVICE;
variable PROOF_SOCKET_DIR ?= undef;

#############################################################
# Load site config and checks mandatory params are defined. #
# Define default values for others.                         #
#############################################################

include { PROOF_CONFIG_SITE };

variable XROOTD_INSTALLATION_DIR ?= error('XROOTD_INSTALLATION_DIR not defined in site configuration: no default.');
variable XROOTD_CONFIG_FILE ?= error('XROOTD_CONFIG_FILE not defined in site configuration: no default.');
variable XROOTD_DAEMON ?= XROOTD_INSTALLATION_DIR+'/bin/'+PKG_ARCH_DEFAULT+'/xrootd';
variable XROOTD_LIB_DIR ?= if ( PKG_ARCH_DEFAULT == 'i386' ) {
                             XROOTD_INSTALLATION_DIR+'/lib';
                           } else {
                             XROOTD_INSTALLATION_DIR+'/lib64';
                           };
variable XROOTD_USER ?= 'xrootd';

variable PROOF_MASTER_NODES ?= error('PROOF_MASTER_NODE must be defined to build the PROOF config file (no default)');
variable PROOF_WORKER_NODES ?= error('PROOF_WORKER_NODES must be defined to build the PROOF config file (no default)');


#########################
# Create startup script #
#########################

variable PROOF_STARTUP_CONTENTS ?= <<EOF;
#! /bin/sh
#
# xrootd    Start/Stop the XROOTD daemon
#
# chkconfig: 345 99 0
# description: The xrootd daemon is used to as file server and starter of
#              the PROOF worker processes.
#
# processname: xrootd
# pidfile: /var/run/xrootd.pid
# config:

XROOTD=/opt/root/bin/xrootd
XRDLIBS=/opt/root/lib
XRDLOG=/var/log/xroot.log

# Source function library.
. /etc/init.d/functions

# Get config.
. /etc/sysconfig/network

# Get xrootd config
[ -f  /etc/sysconfig/xrootd ] && . /etc/sysconfig/xrootd

# Read user config
[ ! -z "$XRDUSERCONFIG" ] && [ -f "$XRDUSERCONFIG" ] && . $XRDUSERCONFIG

# Check that networking is up.
if [ ${NETWORKING} = "no" ]
then
    exit 0
fi

if [ ! -x $XROOTD ]
then
  echo "Xrootd daemon not found ($XROOTD)"
  exit 4
fi

RETVAL=0
prog="xrootd"

export DAEMON_COREFILE_LIMIT=unlimited

start() {
        echo -n $"Starting $prog: "
        # Options are specified in /etc/sysconfig/xrootd .
        # See $ROOTSYS/etc/daemons/xrootd.sysconfig for an example.
        # $XRDUSER *must* be the name of an existing non-privileged user.
        if [ -z "$XRDUSER" ]
        then
          echo "XRDUSER must be defined in site configuration. Aborting"
          RETVAL=5
          return $RETVAL
        fi
        # $XRDCF must be the name of the xrootd configuration file
        if [ -z "$XRDCF" ]
        then
          echo "XRDCF must be defined in site configuration. Aborting"
          RETVAL=5
          return $RETVAL
        fi
        export LD_LIBRARY_PATH=$XRDLIBS:$LD_LIBRARY_PATH
        # Set xrootd log file to be writable by XRDUSER
        touch $XRDLOG
        chown $XRDUSER $XRDLOG
    # limit on 1 GB resident memory, and 2 GB virtual memory
    #ulimit -m 1048576 -v 2097152 -n 65000
        daemon $XROOTD -b -l $XRDLOG -R $XRDUSER -c $XRDCF $XRDDEBUG
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/xrootd
        return $RETVAL
}

stop() {
    [ ! -f /var/lock/subsys/xrootd ] && return 0 || true
        echo -n $"Stopping $prog: "
        killproc xrootd
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/xrootd
    return $RETVAL
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status xrootd
    RETVAL=$?
    ;;
  restart|reload)
    stop
    start
    ;;
  condrestart)
    if [ -f /var/lock/subsys/xrootd ]; then
            stop
            start
        fi
    ;;
  *)
    echo  $"Usage: $0 {start|stop|status|restart|reload|condrestart}"
    exit 1
esac

exit $RETVAL
EOF

'/software/components/filecopy/services' = {
  SELF[escape(PROOF_STARTUP_SCRIPT)] = nlist('config', PROOF_STARTUP_CONTENTS,
                                             'owner', 'root:root',
                                             'perms', '0755');
  SELF;

};

'/software/components/chkconfig/service' = {
  SELF[PROOF_SERVICE] = nlist('on', '',
                              'startstop', true,
                             );
  SELF;
};


#####################################
# Create configuration in sysconfig #
#####################################

include { 'components/sysconfig/config' };
'/software/components/sysconfig/files/xrootd/XROOTD_DIR' = XROOTD_INSTALLATION_DIR;
'/software/components/sysconfig/files/xrootd/XROOTD' = XROOTD_DAEMON;
'/software/components/sysconfig/files/xrootd/XRDUSER' = XROOTD_USER;
'/software/components/sysconfig/files/xrootd/XRDCF' = XROOTD_CONFIG_FILE;
'/software/components/sysconfig/files/xrootd/XRDLIBS' = XROOTD_LIB_DIR;


#####################################################################
# Create xrootd configuration file for PROOF.                       #
# The configuration can be passed explicitly in PROOF_XROOTD_CONFIG #
# or using a template (PROOF_XROOTD_CONFIG_TEMPLATE_FILE).          #
# In both cases, some replacements are attempted to substitute      #
# with variables describing actual configuration.                   #
#####################################################################

variable PROOF_XROOTD_CONFIG_TEMPLATE_FILE ?= 'features/proof/xrootd-config-default';

variable PROOF_XROOTD_CONFIG = {
  if ( is_defined(SELF) ) {
    contents = SELF;
  } else {
    tmp = create(PROOF_XROOTD_CONFIG_TEMPLATE_FILE);
    contents = tmp['contents'];
  };
  contents = replace('PROOF_SANDBOX_AREA',PROOF_SANDBOX_AREA,contents);

  if ( is_defined(PROOF_SOCKET_DIR) ) {
    contents = contents + "\nxpd.sockpathdir " + PROOF_SOCKET_DIR + "\n";
  };

  # If on a master, define master role and list of workers
  if ( index(FULL_HOSTNAME,PROOF_MASTER_NODES) >= 0 ) {
    # Add definition of masters
    contents = contents + "\n";
    foreach (i;master;PROOF_MASTER_NODES) {
      master_role = 'any';   # Both master and worker allowed
      if ( !is_list(PROOF_WORKER_NODES) ||
           (index(master,PROOF_WORKER_NODES) < 0) ) {
        master_role = 'master';
      };
      contents = contents + "if " + master + "\n";
      contents = contents + "  xpd.role " + master_role + "\n";
      contents = contents + "fi\n";
    };

    # Add list of worker nodes.
    # It is possible to define number of CPU to use explicitly using
    # variable PROOF_CORES which is a nlist where keys are worker names.
    # Value can be either positive (number of cores to use) or negative
    # (number of cores reserved).
    contents = contents + "\n";
    foreach (i;wn;PROOF_WORKER_NODES) {
      if ( exists(DB_MACHINE[escape(wn)]) ) {
        wn_hw = create(DB_MACHINE[escape(wn)]);
      } else {
        error(wn + ": hardware not found in machine database");
      };
      cpu_num = length(wn_hw['cpu']);
      if ( cpu_num > 0 ) {
        if ( is_defined(PROOF_CORES[wn]) && (PROOF_CORES[wn] >= 0) ) {
          core_num = PROOF_CORES[wn];
        } else if ( is_defined(wn_hw['cpu'][0]['cores']) ) {
          # If PROOF_CORES[wn] is defined and negative, remove the given
          # number of cores from PROOF config.
          # Else, if WN is a master, remove 1 CPU from the WN config.
          core_num = cpu_num * wn_hw['cpu'][0]['cores'];
          if ( is_defined(PROOF_CORES[wn]) && (PROOF_CORES[wn] < 0) ) {
            core_num = core_num + PROOF_CORES[wn];
          } else if ( index(wn,PROOF_MASTER_NODES) >= 0 ) {
            core_num = core_num -1;
          };
          if ( core_num < 0 ) {
            debug('Computed number of cores to use negative. Resetting to 0.');
            core_num = 0;
          };
        } else {
          core_num = cpu_num;
        };
      } else {
        error(wn+': number of CPU not defined in HW database');
      };
      contents = contents + "xpd.worker worker " + wn + " repeat=" + to_string(core_num) + "\n";
    };
  };

  contents;
};


'/software/components/filecopy/services' = {
  if ( is_defined(PROOF_XROOTD_CONFIG) ) {
    SELF[escape(XROOTD_CONFIG_FILE)] = nlist('config', PROOF_XROOTD_CONFIG,
                                             'owner', 'root:root',
                                             'perms', '0755',
                                             'restart', '/sbin/service xrootd restart');
  };

  SELF;
};


# Must be done at the very end of the configuration
include { 'features/proof/check-proof-daemons' };


