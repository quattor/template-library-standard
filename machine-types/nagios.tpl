#
# Initial version for Nagios server configuration
#
# This template probably requires some modifications to fit in the QWG framework
# Note that the configuration for grid monitoring is currently commented out
# because there is no support for Yaim (yet) in QWG
#
# Contributed by: Ronald Starink    < ronalds AT nikhef DOT nl >
#
unique template machine-types/nagios;

#
# Include base configuration of a gLite node
#
include { 'machine-types/base' };

# Nagios configuration settings
variable NAGIOS_CONFIG_SITE ?= null;
include { NAGIOS_CONFIG_SITE };

# Optional grid monitoring for Nagios
variable NAGIOS_GRID_MONITORING ?= null;
include { NAGIOS_GRID_MONITORING };

# include optional NSCA config
variable NSCA_CONFIG_SITE ?= 'monitoring/nagios/nsca/config';
include { NSCA_CONFIG_SITE };

include { 'monitoring/nagios/config' };

## following only apply when used as grid monitoring host

# CA certs
include { if ( is_defined( NAGIOS_GRID_MONITORING ) ) { 'security/cas' } else { null }; };

# Yaim stuff
## Yaim configuration is not yet supported in QWG, hence the following are commented out
##include { if ( is_defined( NAGIOS_GRID_MONITORING ) ) { 'vo/config' } else { null }; };
##include { if ( is_defined( NAGIOS_GRID_MONITORING ) ) { 'yaim/config' } else { null }; };


## TODO: possibly some trailing includes for QWG
