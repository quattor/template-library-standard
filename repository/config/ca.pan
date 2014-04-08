unique template repository/config/ca;

variable YUM_SNAPSHOT_NS ?= 'repository/snapshot';

@{
desc =  namespace of template associated with CA RPM YUM snapshot
values =  string 
default = YUM_SNAPSHOT_NS
required = no
}

variable YUM_CA_RPM_SNAPSHOT_NS ?= YUM_SNAPSHOT_NS;

@{
desc =  YUM snapshot date to use for CA RPMs
values =  string matching a YUM snapshot at site (typically YYYYMMDD) or null to disable usage of a YUM snapshot
default = YUM_SNAPSHOT_DATE
required = no
}
variable YUM_CA_RPM_SNAPSHOT_DATE ?= if ( is_null(YUM_CA_RPM_SNAPSHOT_DATE) ) {
                                       SELF;
                                     } else if ( is_defined(YUM_SNAPSHOT_DATE) ) {
                                       YUM_SNAPSHOT_DATE;
                                     } else {
                                       undef;
                                     };

@{
desc = template describing RPM repository holding the CA descriptions (RPMs)
values =  a template or null to disable it
default = repository/ca
required = no
}
variable SECURITY_CA_RPM_REPOSITORY ?= list("ca");

include { 'quattor/functions/repository' };

'/software/repositories' = {
  if ( is_defined(YUM_CA_RPM_SNAPSHOT_DATE) ) {
    add_repositories(SECURITY_CA_RPM_REPOSITORY,YUM_CA_RPM_SNAPSHOT_NS);
  } else {
    add_repositories(SECURITY_CA_RPM_REPOSITORY);
  };
};

