unique template features/docker/el6/config;

# Parameters
variable DOCKER_DATA_DIR ?= if(!is_defined(DOCKER_SRV_OPTS)){
    error("one of DOCKER_DATA_DIR and DOCKER_SRV_OPTS should be defined");
};

variable DOCKER_SRV_ADD_OPTS ?= '';

#We keep the possibility to directly define this variable to cope with some old config at GRIF
variable DOCKER_SRV_OPTS ?= format('"%s -g %s"', DOCKER_SRV_ADD_OPTS, DOCKER_DATA_DIR);

# DOCKER_OLD_PACKAGE: deprecated, use DOCKER_PACKAGE instead
variable DOCKER_OLD_PACKAGE ?= false;

variable DOCKER_PACKAGE ?=  if ( DOCKER_OLD_PACKAGE ) {
                                'docker-io'
                            } else {
                                'docker-engine'
                            };

# Sysconfig for the docker service (EL6 only)
include 'components/sysconfig/config';
prefix '/software/components/sysconfig/files/docker';
'DOCKER_TMPDIR' =   if(is_defined(DOCKER_DATA_DIR)){
                        DOCKER_DATA_DIR + '/tmp';
                    } else {
                        null
                    };
'other_args' = DOCKER_SRV_OPTS;
