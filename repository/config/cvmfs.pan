unique template repository/config/cvmfs;

variable YUM_SNAPSHOT_NS ?= 'repository/snapshot';

@{
desc =  namespace of template associated with CVMFS YUM snapshot
values =  string
default = YUM_SNAPSHOT_NS
required = no
}
variable YUM_CVMFS_SNAPSHOT_NS ?= YUM_SNAPSHOT_NS;

@{
desc =  YUM snapshot date to use for CVMFS
values =  string matching a YUM snapshot at site (typically YYYYMMDD) or null to disable usage of a YUM snapshot
default = YUM_SNAPSHOT_DATE
required = no
}
variable YUM_CVMFS_SNAPSHOT_DATE ?= if ( is_null(YUM_CVMFS_SNAPSHOT_DATE) ) {
                                      SELF;
                                    } else if ( is_defined(YUM_SNAPSHOT_DATE) ) {
                                      YUM_SNAPSHOT_DATE;
                                    } else {
                                      undef;
                                    };

include { 'quattor/functions/repository' };

# Repository contining the RPMs
variable CVMFS_RPM_REPOSITORY ?= list('CernVM-FS');

'/software/repositories' = {
  if ( is_defined(YUM_CVMFS_SNAPSHOT_DATE) ) {
    add_repositories(CVMFS_RPM_REPOSITORY,YUM_CVMFS_SNAPSHOT_NS);
  } else {
    add_repositories(CVMFS_RPM_REPOSITORY);
  };
};

