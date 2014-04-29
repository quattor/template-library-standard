
template machine-types/pakiti-server;

# Configure base OS
include { 'machine-types/core' };

# Add perfSONAR configuration
include { 'features/pakiti/config' };


