unique template features/docker/service;

#Parameters
variable DOCKER_DATA_DIR ?= if(!is_defined(DOCKER_SRV_OPTS)){
  error("one of DOCKER_DATA_DIR and DOCKER_SRV_OPTS should be defined");
};

variable DOCKER_SRV_ADD_OPTS ?= '';

#We keep the possibility to directly define this variable to cope with some old config at GRIF
variable DOCKER_SRV_OPTS ?= '"' + DOCKER_SRV_ADD_OPTS + ' -g ' + DOCKER_DATA_DIR + '"';

variable DOCKER_OLD_PACKAGE ?= false; 

#Install the docker package
include {'components/spma/config'};

'/software/packages/' = if(DOCKER_OLD_PACKAGE){
  SELF[escape('docker-io')] = nlist();
  SELF;
}else{
  SELF[escape('docker-engine')] = nlist();
  SELF;
};


#OS dependent setup
include{
  if(match(OS_VERSION_PARAMS['major'], '[es]l6')){
    'features/docker/el6/service';
  }else{
    'features/docker/el7/service';
  };
};

