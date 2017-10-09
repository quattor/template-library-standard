unique template features/docker/core;

#Parameters
variable DOCKER_DATA_DIR ?= if(!is_defined(DOCKER_SRV_OPTS)){
    error("one of DOCKER_DATA_DIR and DOCKER_SRV_OPTS should be defined");
};

variable DOCKER_SRV_ADD_OPTS ?= '';

#We keep the possibility to directly define this variable to cope with some old config at GRIF
variable DOCKER_SRV_OPTS ?= '"' + DOCKER_SRV_ADD_OPTS + ' -g ' + DOCKER_DATA_DIR + '"';

#OS dependent setup
include {
    if ( OS_VERSION_PARAMS['family'] == 'el' ) {
        format('features/docker/el%s/config', OS_VERSION_PARAMS['majorversion']);
    } else {
        error(format('Docker configuration: unsupported OS version (%s)', OS_VERSION_PARAMS['major']));
    };
};

# Sysconfig for the docker service
include {'components/sysconfig/config'};

prefix '/software/components/sysconfig/files/docker';

'DOCKER_TMPDIR' = if(is_defined(DOCKER_DATA_DIR)){
    DOCKER_DATA_DIR + '/tmp';
}else{
    null
};
'other_args' = DOCKER_SRV_OPTS;

#Set the docker service to be running at boot
include {'components/chkconfig/config'};

prefix '/software/components/chkconfig/service/docker';

'on' = "";
'add' = true;
'startstop' = true;


