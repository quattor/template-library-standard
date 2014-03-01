# This template updates the loadpath with the gLite version to be used
# on the current node.
# By default does nothing, except if NODE_GLITE_VERSION_DB is defined.
# When nothing is done, the include path passed to panc must have a
# valid path for gLite-related templates. The absence of a gLite version
# explicit definition can be tested by checking if
# NODE_GLITE_VERSION_LOADPATH is defined.

unique template glite/version/config;

variable NODE_GLITE_VERSION_DB ?= null;

# Load DB of gLite version per machine
include { NODE_GLITE_VERSION_DB };

# Find version to run on this node based on node name or OS version
# and update loadpath accordingly.
variable NODE_GLITE_VERSION_LOADPATH = if ( is_defined(NODE_GLITE_VERSION[escape(FULL_HOSTNAME)]) ) {
                                         NODE_GLITE_VERSION[escape(FULL_HOSTNAME)];
                                       } else if ( is_defined(NODE_GLITE_VERSION_DEFAULT[OS_VERSION_PARAMS['major']]) ) {
                                         NODE_GLITE_VERSION_DEFAULT[OS_VERSION_PARAMS['major']];
                                       } else {
                                         undef;
                                       };

variable LOADPATH = {
  if ( is_defined(NODE_GLITE_VERSION_LOADPATH) ) {
    debug(FULL_HOSTNAME+': adding '+NODE_GLITE_VERSION_LOADPATH+' to PAN loadpath');
    SELF[length(SELF)] = NODE_GLITE_VERSION_LOADPATH;
  } else {
    debug(FULL_HOSTNAME+': no gLite version defined');
  };
  SELF;
};
