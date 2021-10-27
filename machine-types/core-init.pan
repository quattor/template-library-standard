# This template initialises the variables related to the site, cluster and the host.
# Factorised from core.pan to adresse use cases where some configuration is
# needed between this part and the main part of the OS configuration.

template machine-types/core-init;

# Include static information and derived global variables.
variable SITE_DB_TEMPLATE ?= 'site/databases';
include SITE_DB_TEMPLATE;
variable SITE_GLOBAL_VARS_TEMPLATE ?= 'site/global_variables';
include SITE_GLOBAL_VARS_TEMPLATE;

# define site functions
variable SITE_FUNCTIONS_TEMPLATE ?= if_exists('site/functions');
include SITE_FUNCTIONS_TEMPLATE;

# Package management core functions
include 'components/spma/functions';

# profile_base for profile structure
include 'quattor/profile_base';

# hardware
include 'hardware/functions';
"/hardware" = if ( exists(DB_MACHINE[escape(FULL_HOSTNAME)]) ) {
    create(DB_MACHINE[escape(FULL_HOSTNAME)]);
} else {
    error(FULL_HOSTNAME + " : hardware not found in machine database");
};
variable MACHINE_PARAMS_CONFIG ?= undef;
include MACHINE_PARAMS_CONFIG;
"/hardware" = if ( exists(MACHINE_PARAMS) && is_dict(MACHINE_PARAMS) ) {
    update_hw_params();
} else {
    SELF;
};


# Cluster specific configuration
variable CLUSTER_INFO_TEMPLATE ?= 'site/cluster_info';
include CLUSTER_INFO_TEMPLATE;


# Select OS version based on machine name
include 'os/version';
