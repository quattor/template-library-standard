unique template features/maven2/config;


# Include RPMs
variable MAVEN_JPACKAGE_VARIANT = {
  os_major = "";
  if ( is_defined(NODE_OS_VERSION) ) {
    if ( match(NODE_OS_VERSION, '^(sl|rhel|centos)[4-5]') ) {
      os_major = "sl4";
    } else if ( match(NODE_OS_VERSION, '^(sl|rhel|centos)[6-9]') ) {
      os_major = "sl6";
    };
  };
  if ( os_major == "sl4" ) {
    'jpp5';
  } else if ( os_major == "sl6" ) {
    'jpp1.7';
  } else {
    '';
  };
};
variable MAVEN_INCLUDE = {
  templ = if_exists('features/maven2/rpms/'+MAVEN_JPACKAGE_VARIANT+'/config');
  if ( is_defined(templ) ) {
    debug('Configuring Maven: executing template '+templ);
  } else {
    debug("Maven configuration template for JPackage variant '"+MAVEN_JPACKAGE_VARIANT+"' not found: skipping Maven configuration");
  };
  templ;
};
include { MAVEN_INCLUDE };
