unique template features/docker/el7/config;

variable DOCKER_PACKAGE ?= 'docker-ce';


@{
descr = options for the daemon.json
values = dict
default = data-root if defined (DOCKER_DATA_DIR variable)
required = No
}
variable DOCKER_SRV_OPTS ?= dict();

variable DOCKER_SRV_OPTS = {
    if ( is_defined(DOCKER_DATA_DIR) ) {
        SELF['data-root'] = DOCKER_DATA_DIR;
        if ( !is_defined(SELF['storage-driver']) ) {
            SELF['storage-driver'] = "overlay";
        };
    };

    SELF;
};

# Configure daemon.json if needed
include if( length(DOCKER_SRV_OPTS) > 0 ) 'features/docker/el7/daemon_config';
