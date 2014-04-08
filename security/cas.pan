unique template security/cas;

variable RPMS_CONFIG_SUFFIX ?= '';

@{
desc = Allows site to use a CA trust policy different from the default (EGI) one
values =  template namespace
default = common/security/ca-policy-egi-core
required = yes
}
variable SECURITY_CA_TRUST_POLICY ?= 'security/ca-policy-egi-core' + RPMS_CONFIG_SUFFIX;

@{
desc = RPM specifying a dummy CA (invalid) to work around problems in Apache with large number of CAs
values =  list("rpm-name","rpm-version") or null to disable it
default = standard dummy-CA RPM
required = no
}
variable SECURITY_CA_DUMMY ?= list("dummy-ca-certs","20090630-1");

# Include CA trust policy
include { SECURITY_CA_TRUST_POLICY };

# Configure RPM repository holding CA descriptions
include { 'repository/config/ca' };

# Add dummy CA to workaround an Apache issue with large number of CAs
"/software/packages" = {
  if ( is_defined(SECURITY_CA_DUMMY) ) {
    if ( is_list(SECURITY_CA_DUMMY) && (length(SECURITY_CA_DUMMY) == 2) ) {
      pkg_repl(SECURITY_CA_DUMMY[0],SECURITY_CA_DUMMY[1],"noarch");
    } else {
      error('SECURITY_CA_DUMMY must be a list with 2 elements (rpm-name,rpm-version)');
    };
  };
  SELF;
};

