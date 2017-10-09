unique template features/docker/el7/config;

@{
descr = name of the Docker package
values = string
default = docker-ce
required = No
}
variable DOCKER_PACKAGE ?= 'docker-ce';


# Add package
include {'components/spma/config'};
'/software/packages/' = pkg_repl(DOCKER_PACKAGE);


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


