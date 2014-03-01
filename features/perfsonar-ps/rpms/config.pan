unique template features/perfsonar-ps/rpms/config;

#
# Add RPMs
#
variable PERFSONAR_VERSION ?= '3.2.2';
include {'features/perfsonar-ps/rpms/v' + PERFSONAR_VERSION };
