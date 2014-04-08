
template machine-types/perfsonar-ps;

# Configure base OS
include { 'machine-types/core' };

# Add perfSONAR configuration
include { 'personality/perfsonar-ps/config' };


