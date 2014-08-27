############################################################
#
# template machine-types/core
#
# Defines bare minimum configuration (core) for a node.
#
# RESPONSIBLE: Christos Triantafyllidis <ctria@grid.auth.gr>
#
############################################################

template machine-types/core;

# Include static information and derived global variables.
variable SITE_DB_TEMPLATE ?= if_exists('pro_site_databases');
variable SITE_DB_TEMPLATE ?= 'site/databases';
include { SITE_DB_TEMPLATE };
variable SITE_GLOBAL_VARS_TEMPLATE ?= if_exists('pro_site_global_variables');
variable SITE_GLOBAL_VARS_TEMPLATE ?= 'site/global_variables';
include { SITE_GLOBAL_VARS_TEMPLATE };

#
# define site functions
#
variable SITE_FUNCTIONS_TEMPLATE ?= if_exists('site/functions');
variable SITE_FUNCTIONS_TEMPLATE ?= if_exists('pro_site_functions');
include { SITE_FUNCTIONS_TEMPLATE };

#
# profile_base for profile structure
#
include { 'quattor/profile_base' };

#
# NCM core components
#
include { 'components/spma/config' };
include { 'components/grub/config' };


#
# hardware
#
include { 'hardware/functions' };
"/hardware" = if ( exists(DB_MACHINE[escape(FULL_HOSTNAME)]) ) {
                  create(DB_MACHINE[escape(FULL_HOSTNAME)]);
              } else {
                  error(FULL_HOSTNAME + " : hardware not found in machine database");
              };
variable MACHINE_PARAMS_CONFIG ?= undef;
include { MACHINE_PARAMS_CONFIG };
"/hardware" = if ( exists(MACHINE_PARAMS) && is_nlist(MACHINE_PARAMS) ) {
                update_hw_params();
              } else {
                SELF;
              };


# Cluster specific configuration
variable CLUSTER_INFO_TEMPLATE ?= if_exists('pro_site_cluster_info');
variable CLUSTER_INFO_TEMPLATE ?= 'site/cluster_info';
include { CLUSTER_INFO_TEMPLATE };


# common site machine configuration
variable SITE_CONFIG_TEMPLATE ?= if_exists('pro_site_config');
variable SITE_CONFIG_TEMPLATE ?= 'site/config';
include { SITE_CONFIG_TEMPLATE };


# File system configuration.
# filesystem/config is a generic template for configuring file systems : use if it is present. It requires
# a site configuration template passed in FILESYSTEM_LAYOUT_CONFIG_SITE (same name as previous template
# but not the same contents).
variable FILESYSTEM_LAYOUT_CONFIG_SITE ?= if_exists("site/filesystems/base");
variable FILESYSTEM_LAYOUT_CONFIG_SITE ?= error("No file system layout template defined");
variable FILESYSTEM_CONFIG_SITE ?= 'filesystem/config';

# Select OS version based on machine name
include { 'os/version' };

variable OS_TEMPLATE_NAMESPACE = true;


# Define OS related namespaces
variable OS_NS_ROOT = 'config/';
variable OS_NS_OS = OS_NS_ROOT + 'os/';
variable OS_NS_CONFIG ?= if ( is_defined(if_exists(OS_NS_ROOT+'os/base')) ) {
                           OS_NS_ROOT + 'os/';
                         } else {
                           OS_NS_ROOT + 'core/';
                         };
variable OS_NS_QUATTOR = OS_NS_ROOT + 'quattor/';
variable OS_NS_REPOSITORY ?= 'repository/';
#
# software packages
#
include { 'pan/functions' };

#
# Configure Bind resolver
#
include { 'site/named' };


#
# Include OS version dependent RPMs
#
variable SERVICE_OS_BASE_TEMPLATE = {
  if ( is_defined(OS_NS_CONFIG) ) {
    OS_NS_CONFIG + "base";
  } else {
    undef;
  };
};
include { SERVICE_OS_BASE_TEMPLATE };


#
# Quattor client software
#
include { 'quattor/client/config' };


# Configure filesystem layout.
# Must be done after NFS initialisation as it may tweak some mount points.
include { return(FILESYSTEM_CONFIG_SITE) };

#
# AII component must be included after much of the other setup. 
#
include { OS_NS_QUATTOR + 'aii' };


# 
# Add local users if some configured
#
variable USER_CONFIG_INCLUDE = if ( exists(USER_CONFIG_SITE) && is_defined(USER_CONFIG_SITE) ) {
                                 return('users/config');
                               } else {
                                 return(null);
                               };
include { USER_CONFIG_INCLUDE };

#
# Add site specific configuration if any
#
variable GLITE_BASE_CONFIG_SITE ?= null;
include GLITE_BASE_CONFIG_SITE;

# Default repository configuration template 
variable PKG_REPOSITORY_CONFIG ?= 'repository/config';
