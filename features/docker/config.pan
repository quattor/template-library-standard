unique template features/docker/config;

variable DOCKER_BACKUP ?= false;
variable DOCKER_PIPEWORK ?= false;

@{
descr = YUM repository containing Docker packages
values = string
default = null
required = No
}

include 'features/docker/core';

include if ( DOCKER_BACKUP ) 'features/docker/backup';

include if( DOCKER_PIPEWORK ) 'features/docker/pipework';

# Configure Docker YUM repository if necessary
variable SITE_REPOSITORY_LIST = {
    if ( is_defined(DOCKER_YUM_REPOSITORY) ) {
        SELF[length(SELF)] = format('%s', DOCKER_YUM_REPOSITORY);
    };
    SELF;
};

