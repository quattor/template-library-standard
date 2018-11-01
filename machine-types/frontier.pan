
template machine-types/frontier;

# CREATE_HOME must be defined as undef
variable CREATE_HOME ?= undef;

include 'machine-types/core';

include 'features/frontier/config';

