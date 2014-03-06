# Standard repositories  for Internet2 specific components
 
unique template personality/perfsonar-ps/repository/config;
 
include { 'quattor/functions/repository' };

# Include EGI CA repository
variable SITE_REPOSITORY_LIST ?= list();
variable SITE_REPOSITORY_LIST = append('ca');

# Local repository configuration overrides
variable SITE_REPOSITORY_CONFIG ?= nlist();
variable SITE_REPOSITORY_CONFIG = npush(
#    'sl6.._x86_64', nlist('excludepkgs', list('kernel*')),
);

variable SITE_REPOSITORY_LIST = append('origin/internet2_el6_x86_64_main');
variable SITE_REPOSITORY_LIST = append('origin/web100_el6_x86_64_main');


