
template machine-types/frontier;

# UMD site configuration
variable GLITE_BASE_CONFIG_SITE ?= undef;

# CREATE_HOME must be defined as undef
variable CREATE_HOME ?= undef;

include 'machine-types/core';

include GLITE_BASE_CONFIG_SITE;

include 'features/frontier/config';

