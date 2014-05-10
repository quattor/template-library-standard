# Standard network configuration, executed as part of the OS base configuration in sl5.x/6.x/...
# Can be disabled setting OS_BASE_CONFIGURE_NETWORK to false

unique template os/network/config;

variable OS_NETWORK_CONFIG_SITE ?= null;

include { 'components/network/config' };
include { 'quattor/functions/network' };

"/system/network/hostname" ?= HOSTNAME;
"/system/network/domainname" ?= DOMAIN;
"/system/network/nameserver" ?= NAMESERVERS;

variable NETWORK_DEFAULT_GATEWAY ?= NETWORK_PARAMS["gateway"];
variable NETWORK_DEFAULT_GATEWAY ?= null;
'/system/network/default_gateway' ?= NETWORK_DEFAULT_GATEWAY;

'/system/network/interfaces' ?= copy_network_params(NETWORK_PARAMS);

variable DEBUG = debug(OBJECT+' : OS_NETWORK_CONFIG_SITE='+to_string(OS_NETWORK_CONFIG_SITE));
include { OS_NETWORK_CONFIG_SITE };
