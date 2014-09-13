# Standard repositories  for Internet2 specific components
 
unique template repository/config/perfsonar-ps;
 
variable YUM_SNAPSHOT_NS ?= 'repository/snapshot';

@{
desc =  YUM snapshot date to use for  perfSONAR
values =  string matching a YUM snapshot at site (typically YYYYMMDD) or null to disable usage of a YUM snapshot
default = YUM_SNAPSHOT_DATE
required = no
}
variable YUM_INTERNET2_SNAPSHOT_DATE ?= if ( is_null(YUM_INTERNET2_SNAPSHOT_DATE) ) {
                                          SELF;
                                        } else if ( is_defined(YUM_SNAPSHOT_DATE) ) {
                                          YUM_SNAPSHOT_DATE;
                                        } else {
                                          undef;
                                        };

@{
desc =  namespace of templates associated with perfSONAR YUM snapshots
values =  string
default = YUM_SNAPSHOT_NS
required = no
}
variable YUM_INTERNET2_SNAPSHOT_NS ?= if ( is_defined(YUM_INTERNET2_SNAPSHOT_DATE) ) {
                                        YUM_SNAPSHOT_NS;
                                      } else {
                                        'repository/origin';
                                      };

include { 'quattor/functions/repository' };

# Include EGI CA repository
include { 'repository/config/ca' };

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

variable REPOSITORY_INTERNET2_BASE ?= 'internet2_tools';
variable REPOSITORY_INTERNET2_WEB100 ?= 'internet2_kernel';
'/software/repositories' = add_repositories(list(REPOSITORY_INTERNET2_BASE,REPOSITORY_INTERNET2_WEB100),YUM_INTERNET2_SNAPSHOT_NS);


