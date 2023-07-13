# Standard network configuration, executed as part of the OS base configuration in sl5.x/6.x/...
# Can be disabled setting OS_BASE_CONFIGURE_NETWORK to false

unique template os/network/config;

variable OS_NETWORK_CONFIG_SITE ?= null;

include 'components/network/config';
include 'quattor/functions/network';

"/system/network/hostname" ?= HOSTNAME;
"/system/network/realhostname" ?= if ( is_defined(REAL_HOSTNAME) ) REAL_HOSTNAME else null;
"/system/network/domainname" ?= DOMAIN;
"/system/network/nameserver" ?= NAMESERVERS;

variable NETWORK_DEFAULT_GATEWAY ?= NETWORK_PARAMS["gateway"];
variable NETWORK_DEFAULT_GATEWAY ?= null;
'/system/network/default_gateway' ?= NETWORK_DEFAULT_GATEWAY;

'/system/network/interfaces' ?= copy_network_params(NETWORK_PARAMS);


# Disable management of resolv.conf by NetworkManager (EL8+)
include if (
    (OS_VERSION_PARAMS['family'] == 'el') && (OS_VERSION_PARAMS['majorversion'] >= "8")
) 'os/network/network_manager';


# Ste-specific configuration, if any
variable DEBUG = debug('OS_NETWORK_CONFIG_SITE=%s', to_string(OS_NETWORK_CONFIG_SITE));
include OS_NETWORK_CONFIG_SITE;
