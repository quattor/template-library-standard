# This template is the core template used to configure the OS and the basic services.

template machine-types/core;

# Core initializations related to host hardware, cluster and global site variables
# Can be called before executing this template when some specific configurations
# need to be done before configure the OS but require this initial part
include 'machine-types/core-init';


@{
desc = when, true, don't do the filesystem/blockdevice configuration as part of the OS configuration
value = boolean
default = false
required = no
}
variable OS_POSTPONE_FILESYSTEM_CONFIG ?= false;
variable DEBUG = debug('OS_POSTPONE_FILESYSTEM_CONFIG=%s', OS_POSTPONE_FILESYSTEM_CONFIG);

@{
desc = when, true, don't do the AII configuration as part of the OS configuration
value = boolean
default = OS_POSTPONE_FILESYSTEM_CONFIG (AII configuration must be done after the file system configuration)
required = no
}
variable OS_POSTPONE_AII_CONFIG ?= OS_POSTPONE_FILESYSTEM_CONFIG;
variable DEBUG = debug('%s: OS_POSTPONE_AII_CONFIG=%s', OS_POSTPONE_AII_CONFIG);


# Grub configuration module initialisation
include 'components/grub/config';

# common site machine configuration
variable SITE_CONFIG_TEMPLATE ?= 'site/config';
include SITE_CONFIG_TEMPLATE;


# File system configuration.
# filesystem/config is a generic template for configuring file systems : use if it is present. It requires
# a site configuration template passed in FILESYSTEM_LAYOUT_CONFIG_SITE (same name as previous template
# but not the same contents).
variable FILESYSTEM_LAYOUT_CONFIG_SITE ?= if_exists("site/filesystems/base");
variable FILESYSTEM_LAYOUT_CONFIG_SITE ?= error("No file system layout template defined");
variable FILESYSTEM_CONFIG_SITE ?= 'filesystem/config';


# Define OS related namespaces
variable OS_NS_ROOT = 'config/';
variable OS_NS_OS = OS_NS_ROOT + 'core/';
variable OS_NS_CONFIG ?= OS_NS_ROOT + 'core/';
variable OS_NS_QUATTOR = OS_NS_ROOT + 'quattor/';
variable OS_NS_REPOSITORY ?= 'repository/';

# software packages
include 'pan/functions';

# Configure Bind resolver
include 'site/named';


# Include OS version dependent RPMs
variable SERVICE_OS_BASE_TEMPLATE = {
    if ( is_defined(OS_NS_CONFIG) ) {
        OS_NS_CONFIG + "base";
    } else {
        undef;
    };
};
include SERVICE_OS_BASE_TEMPLATE;

# Configure time synchonisation
include if_exists('site/time_synchronisation');

# Quattor client software
include 'quattor/client/config';


# Configure filesystem layout.
# Must be done after NFS initialisation as it may tweak some mount points.
include if ( !OS_POSTPONE_FILESYSTEM_CONFIG ) FILESYSTEM_CONFIG_SITE;

#
# AII component must be included after much of the other setup.
#
include if ( !OS_POSTPONE_AII_CONFIG ) OS_NS_QUATTOR + 'aii';


#
# Add local users if some configured
#
variable USER_CONFIG_INCLUDE = if ( exists(USER_CONFIG_SITE) && is_defined(USER_CONFIG_SITE) ) {
    'users/config';
} else {
    null;
};
include USER_CONFIG_INCLUDE;


# Default repository configuration template
variable PKG_REPOSITORY_CONFIG ?= 'repository/config';
