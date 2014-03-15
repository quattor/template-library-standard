# This template sets loadpath for OS templates according to content of
# table OS_VERSION. If no entry exists for the current machine, no loadpath
# is defined (cluster defaults apply).
# If no OS_VERSION table is provided, nothing is done.
# After standard definitions, local actions can be done if variable
# NODE_OS_VERSION_SITE_CONFIG is defined.

unique template os/version;

variable NODE_OS_VERSION_SITE_CONFIG ?= null;
variable NODE_OS_VERSION_DB ?= null;
variable NODE_OS_VERSION_DEFAULT ?= undef;
variable OS_FLAVOUR_ENABLED ?= false;

# Load defaults
include { 'os/version_db_default' };

include { debug('OS version db = '+to_string(NODE_OS_VERSION_DB)); NODE_OS_VERSION_DB };

# Retrieve OS version for the current machine if defined
variable NODE_OS_VERSION = if ( is_defined(NODE_OS_VERSION_DB) && is_defined(OS_VERSION[escape(FULL_HOSTNAME)]) ) {
                             OS_VERSION[escape(FULL_HOSTNAME)];
                           } else {
                             if ( is_defined(NODE_OS_VERSION_DEFAULT) ) {
                               NODE_OS_VERSION_DEFAULT;
                             } else {
                               # Use debug() rather than error() to
                               # avoid breaking support for legacy OS
                               # versions without namespace support
                               debug('OS version undefined for '+FULL_HOSTNAME+' and no default version defined.');
                               undef;
                             };
                           };

# calculate OS major, minor and arch and define OS flavour if needed
variable OS_VERSION_PARAMS ?= {
  if ( is_string(NODE_OS_VERSION) ) {
    toks = matches(NODE_OS_VERSION, '^([a-z]+)([0-9])([0-9x]+)(?:[_\-](.*))');
    if ( length(toks) < 5 ) {
      error('NODE_OS_VERSION ('+to_string(NODE_OS_VERSION)+') has an unexpected format. Define OS_VERSION_PARAMS explicitly');
    };
    SELF['distribution'] = toks[1];
    SELF['majorversion'] = toks[2];
    # Handle Fedora as a special case where there is no minor version.
    if ( SELF['distribution'] == 'fedora' ) {
      SELF['majorversion'] = SELF['majorversion'] + toks[3];
      toks[3] = '';
    };
    # For backward compatibility: 'major' used to be distrib + major version
    SELF['major'] = SELF['distribution'] + SELF['majorversion'];
    # Remove trailing 0 in minor version.
    SELF['minor'] = replace('0$','',toks[3]);
    SELF['version'] = SELF['major']+toks[3];
    SELF['arch'] = toks[4];
    if ( OS_FLAVOUR_ENABLED ) {
      SELF['flavour'] = 'x'
    };
    debug('OS_VERSION_PARAMS = '+to_string(SELF));
    SELF;
  } else {
    debug('Cannot define OS_VERSION_PARAMS: NODE_OS_VERSION undefined');
    undef;
  };
};

variable OS_FLAVOUR ?= {
    if ( is_defined(OS_VERSION_PARAMS['flavour']) ) {
      OS_VERSION_PARAMS['major'] +"."+OS_VERSION_PARAMS['flavour']+"-"+ OS_VERSION_PARAMS['arch'];
    } else {
      undef;
    };
};


# Define loadpath for OS templates
variable LOADPATH = {
  if ( is_defined(OS_FLAVOUR) ) {
    SELF[length(SELF)] = OS_FLAVOUR
  } else if ( is_defined(NODE_OS_VERSION) ) {
    SELF[length(SELF)] = NODE_OS_VERSION;
  };
  if ( is_defined(SELF) ) {
    SELF;
  } else {
    null;
  };
};

# Tell other templates to use namespaces to access OS related templates
variable OS_TEMPLATE_NAMESPACE ?= if ( is_defined(NODE_OS_VERSION) ) {
                                   true;
                                 } else {
                                   false;
                                 };

# Define GLITE_CONFIG_HACKS if required by selected OS version
variable GLITE_CONFIG_HACKS = if ( is_defined(NODE_OS_VERSION) &&
                                   is_defined(GLITE_CONFIG_HACKS_DB[escape(NODE_OS_VERSION)]) ) {
                                GLITE_CONFIG_HACKS_DB[escape(NODE_OS_VERSION)];
                              } else {
                                SELF;
                              };
                                 
# Add local definitions, if any
# This can be used to do any action, even replace standard
# definitions, if no db file is provided
include { NODE_OS_VERSION_SITE_CONFIG };
