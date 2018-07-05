unique template features/docker/config;

@{
descr = Configure Docker backup
values = boolean
default = false
required = No
}
variable DOCKER_BACKUP ?= false;

@{
descr = Configure Piperwork (communication between containers)
values = boolean
default = false
required = No
}
variable DOCKER_PIPEWORK ?= false;

@{
descr = YUM repository containing Docker packages
values = string
default = null
required = No
}
variable DOCKER_YUM_REPOSITORY ?= null;

@{
descr = name of the Docker package
values = string
default = depends on the OS version
required = No
}
variable DOCKER_PACKAGE ?= null;

@{
descr = list of Docker related groups
value = list of string
default = docker
}
variable DOCKER_GROUPS =    list('docker',
                                );

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

# Protected groups
include 'components/accounts/config';
'/software/components/accounts' = {
    foreach (i; group; DOCKER_GROUPS) {
        SELF['kept_groups'][group] = '';
    };

    SELF;
};
