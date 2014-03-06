
template machine-types/perfsonar-ps;

# perfSONAR-PS needs a specific kernel version (.web100) provided by Internet2
# Kernel version is not necessarily matching the SL ones
variable KERNEL_VERSION_NUM ?= '2.6.32-431.3.1.el6.aufs.web100';

# Configure base OS
variable OS_NS_CONFIG ?= 'config/core/';
include { 'machine-types/core' };

# Add perfSONAR configuration
include { 'personality/perfsonar-ps/config' };


