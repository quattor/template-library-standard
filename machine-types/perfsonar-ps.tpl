
template machine-types/perfsonar-ps;

# perfSONAR-PS needs a specific kernel version (.web100) provided by Internet2
# Kernel version is not necessarily matching the SL ones
variable KERNEL_VERSION_NUM ?= '2.6.18-308.1.1.el5.web100';

# Include base configuration of a gLite node.
# This includes configure NFS service.

variable OS_NS_CONFIG ?= 'config/perfsonar-ps/'; 
include { 'machine-types/core' };

# Add perfSONAR configuration
include { 'features/perfsonar-ps/config' };


# Add internet2 package repository
include { 'features/perfsonar-ps/repository/config' };

