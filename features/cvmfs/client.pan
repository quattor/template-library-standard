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
'/software/components/chkconfig/service' = {
    if (CVMFS_CLIENT_VERSION < '2.1' && ! is_defined(SELF['cvmfs'])) {
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


#
# Create local CERN domain configuration, reload service if changed
#
variable CONTENTS = {
    if (!is_nlist(CVMFS_SERVER_URL_CERN)) {
        error("CVMFS: CVMFS_SERVER_URL_CERN should be an nlist");
    };
    first = true;
    this = 'CVMFS_SERVER_URL="';
    foreach (k; v; CVMFS_SERVER_URL_CERN) {
        if (!first) {
            this = this + ';' + v;
        } else {
            this = this + v;
            first = false;
        };
    };
    this = this + '"' + "\n";
};
'/software/components/filecopy/services/{/etc/cvmfs/domain.d/cern.ch.local}' = nlist(
    'config', CONTENTS,
    'owner', 'root',
    'perms', '0644',
    'restart', CVMFS_SERVICE_RELOAD_COMMAND,
);

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

variable CONTENTS = {
    if (!is_nlist(CVMFS_SERVER_URL_DESY)) {
        error("CVMFS: CVMFS_SERVER_URL_DESY should be an nlist");
    };
    first = true;
    this = 'CVMFS_SERVER_URL="';
    foreach (k; v; CVMFS_SERVER_URL_DESY) {
        if (!first) {
            this = this + ';' + v;
        } else {
            this = this + v;
            first = false;
        };
    };
    this = this + '"' + "\n";
    this = this + "CVMFS_PUBLIC_KEY=/etc/cvmfs/keys/desy.de.pub\n"
};

'/software/components/filecopy/services' = {
    if(CVMFS_DESY_DOMAIN_ENABLED){
        SELF[escape('/etc/cvmfs/domain.d/desy.de.conf')]=nlist(
            'config', CONTENTS,
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
        SELF[escape('/etc/cvmfs/keys/desy.de.pub')]=nlist(
            'config', file_contents('features/cvmfs/keys/desy.de.pub'),
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
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

variable CONTENTS = {
    if (!is_nlist(CVMFS_SERVER_URL_RAL)) {
        error("CVMFS: CVMFS_SERVER_URL_RAL should be an nlist");
    };
    first = true;
    this = 'CVMFS_SERVER_URL="';
    foreach (k; v; CVMFS_SERVER_URL_RAL) {
        if (!first) {
            this = this + ';' + v;
        } else {
            this = this + v;
            first = false;
        };
    };
    this = this + '"' + "\n";
    this = this + "CVMFS_PUBLIC_KEY=/etc/cvmfs/keys/gridpp.ac.uk.pub\n"
};

'/software/components/filecopy/services' = {
    if(CVMFS_RAL_DOMAIN_ENABLED){
        SELF[escape('/etc/cvmfs/domain.d/gridpp.ac.uk.conf')]=nlist(
            'config', CONTENTS,
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
        SELF[escape('/etc/cvmfs/keys/gridpp.ac.uk.pub')]=nlist(
            'config', file_contents('features/cvmfs/keys/gridpp.ac.uk.pub'),
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
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

variable CONTENTS = {
    if (!is_nlist(CVMFS_SERVER_URL_EGI)) {
        error("CVMFS: CVMFS_SERVER_URL_EGI should be an nlist");
    };
    first = true;
    this = 'CVMFS_SERVER_URL="';
    foreach (k; v; CVMFS_SERVER_URL_EGI) {
        if (!first) {
            this = this + ';' + v;
        } else {
            this = this + v;
            first = false;
        };
    };
    this = this + '"' + "\n";
    this = this + "CVMFS_PUBLIC_KEY=/etc/cvmfs/keys/egi.eu.pub\n"
};

'/software/components/filecopy/services' = {
    if(CVMFS_EGI_DOMAIN_ENABLED){
        SELF[escape('/etc/cvmfs/domain.d/egi.eu.conf')]=nlist(
            'config', CONTENTS,
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
        SELF[escape('/etc/cvmfs/keys/egi.eu.pub')]=nlist(
            'config', file_contents('features/cvmfs/keys/egi.eu.pub'),
            'owner', 'root',
            'perms', '0644',
            'restart', CVMFS_SERVICE_RELOAD_COMMAND,
        );
    };
    SELF;
};


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
    SELF;
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
