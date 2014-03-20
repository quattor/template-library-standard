# Standard repositories  for Internet2 specific components
 
unique template personality/perfsonar-ps/repository/config;
 
include { 'quattor/functions/repository' };

# Include EGI CA repository
variable SITE_REPOSITORY_LIST ?= list();
variable SITE_REPOSITORY_LIST = append('ca');

# perfSONAR uses specific kernels: prevent kernel and kernel modules to be fetched from
# OS repositories
variable SITE_REPOSITORY_CONFIG ?= nlist();
variable SITE_REPOSITORY_CONFIG = {
  repository_pattern = escape('sl6..?_x86_64');
  if ( !is_defined(SELF[repository_pattern]) ) {
    SELF[repository_pattern] = nlist();
  };
  kernel_pkgs = list('kernel','kernel-*','kmod-*');
  if ( is_defined(SELF[repository_pattern]['excludepkgs']) ) {
    SELF[repository_pattern]['excludepkgs'] = merge(SELF['sl6.._x86_64']['excludepkgs'],kernel_pkgs);
  } else {
    SELF[repository_pattern]['excludepkgs'] = kernel_pkgs;
  };
  SELF;
};

variable YUM_INTERNET2_SNAPSHOT_NS ?= if ( is_defined(YUM_SNAPSHOT_NS) ) {
                                        YUM_SNAPSHOT_NS;
                                      } else {
                                        'repository/origin';
                                      };
variable REPOSITORY_INTERNET2_BASE ?= 'internet2_el6_x86_64_main';
variable REPOSITORY_INTERNET2_WEB100 ?= 'web100_el6_x86_64_main';
'/software/repositories' = add_repositories(list(REPOSITORY_INTERNET2_BASE,REPOSITORY_INTERNET2_WEB100),YUM_INTERNET2_SNAPSHOT_NS);


