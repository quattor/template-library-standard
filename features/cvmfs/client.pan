unique template features/cvmfs/client;

#
# Configurable variables
#

# List of repositories to configure
variable CVMFS_REPOSITORIES ?= list(
    'alice.cern.ch',
    'atlas.cern.ch',
    'atlas-condb.cern.ch',
    'cms.cern.ch',
    'lhcb.cern.ch',
    'lhcb-conddb.cern.ch',
    'sft.cern.ch',
);

# Cache location (/var/lib/cvmfs by default)
variable CVMFS_CACHE_BASE ?= undef;

# Meta-data memory cache size
variable CVMFS_MEMCACHE_SIZE ?= undef;

# Max disk space used (4GB by default)
variable CVMFS_QUOTA_LIMIT ?= undef;

# Shared local harddisk cache
variable CVMFS_SHARED_CACHE ?= false;

# NFS export
variable CVMFS_NFS_SOURCE ?= false;

# Debug log location (undef by default)
variable CVMFS_DEBUGLOG ?= undef;

# Syslog facility, valid values are '0' through '7'
variable CVMFS_SYSLOG_FACILITY ?= undef;

# Public signing keys directory (/etc/cvmfs/keys by default)
variable CVMFS_KEYS_DIR ?= undef;

# Proxy servers to use, should be set
variable CVMFS_HTTP_PROXY ?= undef;

# Release version
variable CVMFS_CLIENT_VERSION ?= '2.1.19-1';

# Servers for domain cern.ch, sort this according to your location
variable CVMFS_SERVER_URL_CERN ?= nlist(
    'URL-01-CERN', 'http://cvmfs-stratum-one.cern.ch:8000/opt/@org@',
    'URL-02-UK', 'http://cernvmfs.gridpp.rl.ac.uk:8000/opt/@org@',
    'URL-03-BNL', 'http://cvmfs.racf.bnl.gov:8000/opt/@org@',
    'URL-04-FNAL', 'http://cvmfs.fnal.gov:8000/opt/@org@',
);

# Servers for domain desy.de, sort this according to your location
variable CVMFS_SERVER_URL_DESY ?= nlist(
    'URL-01-DESY', 'http://grid-cvmfs-one.desy.de:8000/cvmfs/@fqrn@',
);

# Servers for domain gridpp.ac.uk, sort this according to your location
variable CVMFS_SERVER_URL_RAL ?= nlist(
    'URL-01-RAL', 'http://cvmfs-egi.gridpp.rl.ac.uk:8000/cvmfs/@org@.gridpp.ac.uk',
    'URL-02-NIKHEF', 'http://cvmfs01.nikhef.nl/cvmfs/@org@.gridpp.ac.uk',
);

# Servers for domain egi.eu
variable CVMFS_SERVER_URL_EGI ?= nlist(
    'URL-01-RAL', 'http://cvmfs-egi.gridpp.rl.ac.uk:8000/cvmfs/@org@.egi.eu',
);

# VO specific stuff
variable VO_ATLAS_LOCAL_AREA ?= undef;
variable VO_CMS_LOCAL_SITE ?= undef;


#
# Abort if dependencies not present
#
#variable test = if (!exists('/software/packages/{fuse}')) {
#    error("CVMFS: client requires package 'fuse'");
#};


#
# Add RPMs
#
variable RPMS_CONFIG_SUFFIX ?= '';
include { 'features/cvmfs/rpms' };


#
# Add repository
#
include { 'repository/config/cvmfs' };

#
# Enable service
#
include 'quattor/functions/package';
'/software/components/chkconfig/service' = {
    if ((pkg_compare_version('2.1', CVMFS_CLIENT_VERSION) == -1) && ! is_defined(SELF['cvmfs'])) {
        SELF['cvmfs'] = nlist('on', '', 'startstop', false);
    };
    SELF;
};


#
# Configure autofs component, if already included
#
'/software/components' = {
    if (exists('/software/components/autofs/maps')) {
        autofs = SELF['autofs'] ;
        if(!is_defined(autofs['maps']['cvmfs'])) {
            autofs['maps']['cvmfs'] = nlist(
                'enabled', true,
                'preserve', true,
                'mapname', '/etc/auto.cvmfs',
                'type', 'program',
                'mountpoint', '/cvmfs',
            );
        };
        SELF['autofs'] = autofs;
    };
    SELF;
};


#
# Create local default configuration, reload service if changed
#
variable CONTENTS = {
    if (!is_string(CVMFS_HTTP_PROXY)) {
        error("CVMFS: CVMFS_HTTP_PROXY should be a string");
    };
    this = 'CVMFS_REPOSITORIES=' + to_lowercase(replace('[^\w\-\.,]', '', to_string(CVMFS_REPOSITORIES))) + "\n";
    if (is_string(CVMFS_CACHE_BASE)) {
        this = this + 'CVMFS_CACHE_BASE=' + CVMFS_CACHE_BASE + "\n";
    };
    if (is_defined(CVMFS_MEMCACHE_SIZE)) {
        this = this + 'CVMFS_MEMCACHE_SIZE=' + to_string(CVMFS_MEMCACHE_SIZE) + "\n";
    };
    if (is_defined(CVMFS_QUOTA_LIMIT)) {
        this = this + 'CVMFS_QUOTA_LIMIT=' + to_string(CVMFS_QUOTA_LIMIT) + "\n";
    };
    if (is_defined(CVMFS_SHARED_CACHE) && CVMFS_SHARED_CACHE) {
        this = this + "CVMFS_SHARED_CACHE=yes\n";
    };
    if (is_defined(CVMFS_NFS_SOURCE) && CVMFS_NFS_SOURCE) {
        this = this + "CVMFS_NFS_SOURCE=yes\n";
    };
    if (is_defined(CVMFS_SYSLOG_FACILITY)) {
        this = this + 'CVMFS_SYSLOG_FACILITY=' + to_string(CVMFS_SYSLOG_FACILITY) + "\n";
    };
    if (is_defined(CVMFS_KEYS_DIR)) {
        this = this + 'CVMFS_KEYS_DIR=' + to_string(CVMFS_KEYS_DIR) + "\n";
    };
    if (is_defined(CVMFS_DEBUGLOG)) {
        this = this + 'CVMFS_DEBUGLOG=' + to_string(CVMFS_DEBUGLOG) + "\n";
    };
    if (is_defined(CVMFS_MOUNT_RW)) {
        this = this + "CVMFS_MOUNT_RW=yes\n";
    };
    this = this + 'CVMFS_HTTP_PROXY="' + CVMFS_HTTP_PROXY + '"' + "\n";
    this;
};
variable CVMFS_SERVICE_RELOAD_COMMAND ?= {
    if (CVMFS_CLIENT_VERSION < '2.1') {
        'service cvmfs reload';
    } else {
        'cvmfs_config reload';
    };
};
include { 'components/filecopy/config' };
'/software/components/filecopy/services/{/etc/cvmfs/default.local}' = nlist(
    'config', CONTENTS,
    'owner', 'root',
    'perms', '0644',
    'restart', CVMFS_SERVICE_RELOAD_COMMAND,
);


function cvmfs_add_key = {
  if (ARGC < 2) {
    error('number of arguments must be at least 2');
  };

  pubkey_name = ARGV[0];
  pubkey_file = ARGV[1];

  SELF[escape('/etc/cvmfs/keys/' + pubkey_name)]=nlist(
      'config', file_contents(pubkey_file),
      'owner', 'root',
      'perms', '0644',
      'restart', CVMFS_SERVICE_RELOAD_COMMAND,
  );

  return(SELF);
};

function cvmfs_add_config_file = {
  if (ARGC < 3) {
    error('number of arguments must be at least 3');
  };

  if (!CVMFS_CLIENT_ENABLED) {
      return(SELF);
  };


  config_file = ARGV[0];
  server_url = ARGV[1];
  destination = ARGV[2];
  keyfile = undef;

  if (ARGC > 3) {
      keyfile = ARGV[3];
  };

  first = true;
  contents = 'CVMFS_SERVER_URL="';
  foreach (k; v; server_url) {
    if (!first) {
      contents = contents + ';' + v;
    } else {
        contents = contents + v;
        first = false;
    };
  };

  contents = contents + '"' + "\n";

  if (is_defined(keyfile)) {
      contents = contents + "CVMFS_PUBLIC_KEY=/etc/cvmfs/keys/" + keyfile + "\n";
  };

  SELF[escape('/etc/cvmfs/' + destination + '/' + config_file)]=nlist(
      'config', contents,
      'owner', 'root',
      'perms', '0644',
      'restart', CVMFS_SERVICE_RELOAD_COMMAND,
  );

  return(SELF);
};

function cvmfs_add_server = {
  if (ARGC < 2) {
    error('number of arguments must be at least 2');
  };

  domain_name = ARGV[0];
  server_url = ARGV[1];

  return(cvmfs_add_config_file(domain_name + '.conf', server_url, 'domain.d', domain_name + '.pub'));
};

function cvmfs_add_repo = {
  if (ARGC < 2) {
    error('number of arguments must be at least 2');
  };

  repo_name = ARGV[0];
  server_url = ARGV[1];

  return(cvmfs_add_config_file(repo_name + '.conf', server_url, 'config.d', repo_name + '.pub'));
};

#
# Create local CERN domain configuration, reload service if changed
#
'/software/components/filecopy/services' = cvmfs_add_config_file('cern.ch.local', CVMFS_SERVER_URL_CERN, 'domain.d');

#
# Create local DESY domain configuration, reload service if changed
#

variable CVMFS_DESY_DOMAIN_ENABLED = {
    foreach(i;rep;CVMFS_REPOSITORIES){
        if(match(rep,'desy.de$')){
            return(true);
        };
    };
    return(false);
};

'/software/components/filecopy/services' = {
    if(CVMFS_DESY_DOMAIN_ENABLED){
        this = SELF;

        this = cvmfs_add_server('desy.de', CVMFS_SERVER_URL_DESY);
        this = cvmfs_add_key('desy.de.pub', 'features/cvmfs/keys/desy.de.pub');

        return(this);
    };
    SELF;
};


#
# Create local RAL domain configuration, reload service if changed
#

variable CVMFS_RAL_DOMAIN_ENABLED = {
    foreach(i;rep;CVMFS_REPOSITORIES){
        if(match(rep,'gridpp.ac.uk$')){
            return(true);
        };
    };
    return(false);
};

'/software/components/filecopy/services' = {
    if(CVMFS_RAL_DOMAIN_ENABLED){
        this = SELF;

        this = cvmfs_add_server('gridpp.ac.uk', CVMFS_SERVER_URL_RAL);
        this = cvmfs_add_key('gridpp.ac.uk.pub', 'features/cvmfs/keys/gridpp.ac.uk.pub');

        return(this);
    };
    SELF;
};

#
# Create local EGI domain configuration, reload service if changed
#

variable CVMFS_EGI_DOMAIN_ENABLED = {
    foreach(i;rep;CVMFS_REPOSITORIES){
        if(match(rep,'egi.eu$')){
            return(true);
        };
    };
    return(false);
};

'/software/components/filecopy/services' = {
    if(CVMFS_EGI_DOMAIN_ENABLED){
        this = SELF;

        this = cvmfs_add_server('egi.eu', CVMFS_SERVER_URL_EGI);
        this = cvmfs_add_key('egi.eu.pub', 'features/cvmfs/keys/egi.eu.pub');

        return(this);
    };
    SELF;
};

#
# Create user-defined CVMFS repositories and domains
#

#
# Add custom domains through predefinition of variable CVMFS_EXTRA_DOMAINS
#
# It should be defined as in this example:
# variable CVMFS_EXTRA_DOMAINS ?= nlist('example.org',
#                                             nlist('server_urls', nlist('URL-NAME1', 'http://cvmfs1.example.org/cvmfs/@org@.example.org',
#                                                                        'URL-NAME2', 'http://cvmfs2.example.org/cvmfs/@org@.example.org'),
#                                             'pubkeys_file', 'cvmfs/keys/example.org.pub' # cvmfs/keys/example.org.pub is a local file in your template source distribution
#                                             ),
#                                    );

variable CVMFS_EXTRA_DOMAINS ?= undef;

function cvmfs_configure_extra_domains = {
    if (!is_defined(CVMFS_EXTRA_DOMAINS)) {
        return(SELF);
    };

    this = SELF;

    foreach (domain_name; domain_def; CVMFS_EXTRA_DOMAINS) {
        this = cvmfs_add_server(domain_name, domain_def['server_urls']);
        this = cvmfs_add_key(domain_name + '.pub', domain_def['pubkeys_file']);
    };

    return(this);
};

#
# Add custom domains through predefinition of variable CVMFS_EXTRA_REPOSITORIES
#
# It should be defined as in this example:
# variable CVMFS_EXTRA_REPOSITORIES ?= nlist('vo.example.org',
#                                             nlist('server_urls', nlist('URL-NAME1', 'http://cvmfs1.example.org/cvmfs/vo.example.org',
#                                                                        'URL-NAME2', 'http://cvmfs2.example.org/cvmfs/vo.example.org'),
#                                             'pubkeys_file', 'cvmfs/keys/vo.example.org.pub' # cvmfs/keys/vo.example.org.pub is a local file in your template source distribution
#                                             ),
#                                    );

variable CVMFS_EXTRA_REPOSITORIES ?= undef;

function cvmfs_configure_extra_repos = {
    if (!is_defined(CVMFS_EXTRA_REPOSITORIES)) {
        return(SELF);
    };

    this = SELF;

    foreach (repo_name; repo_def; CVMFS_EXTRA_REPOSITORIES) {
        this = cvmfs_add_repo(repo_name, repo_def['server_urls']);
        this = cvmfs_add_key(repo_name + '.pub', repo_def['pubkeys_file']);
    };

    return(this);
};

'/software/components/filecopy/services' = cvmfs_configure_extra_domains();

'/software/components/filecopy/services' = cvmfs_configure_extra_repos();


#
# fuse filesystem sharing is required
#
'/software/components/filecopy/services/{/etc/fuse.conf}' = nlist(
    'config', "user_allow_other\n",
    'owner', 'root',
    'perms', '0644'
);


#
# Add variable for ATLAS local site config, if defined
#
include {'components/profile/config'};
'/software/components/profile/env' = {
    if (is_defined(VO_ATLAS_LOCAL_AREA)) {
        SELF['ATLAS_LOCAL_AREA'] = VO_ATLAS_LOCAL_AREA;
    };
    if ( is_defined(SELF) ) {
      SELF;
    } else {
      null;
    };
};


#
# Add variable for CMS site name, if defined
#
'/software/components/filecopy/services' = {
    if (is_defined(VO_CMS_LOCAL_SITE)) {
        SELF[escape('/etc/cvmfs/config.d/cms.cern.ch.local')] = nlist(
            'config', "export CMS_LOCAL_SITE=" + VO_CMS_LOCAL_SITE + "\n",
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
    };
    SELF;
};


#
# Include cleanup cron job, disabled by default
#
variable CVMFS_ENABLE_CLIENT_CLEANUP ?= false;
include { if (is_boolean(CVMFS_ENABLE_CLIENT_CLEANUP) && CVMFS_ENABLE_CLIENT_CLEANUP) 'features/cvmfs/client-cleanup'};
