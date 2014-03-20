
template machine-types/perfsonar-ps;

# Configure base OS
variable OS_NS_CONFIG ?= 'config/core/';
include { 'machine-types/core' };

# Add perfSONAR configuration
include { 'personality/perfsonar-ps/config' };


