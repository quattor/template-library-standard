unique template features/docker/params;

variable DOCKER_DATA_DIR ?= if(!is_defined(DOCKER_SRV_OPTS)){
  error("one of DOCKER_DATA_DIR and DOCKER_SRV_OPTS should be defined");
};

variable DOCKER_SRV_ADD_OPTS ?= '';

#We keep the possibility to directly define this variable to cope with some old config at GRIF
variable DOCKER_SRV_OPTS ?= '"' + DOCKER_SRV_ADD_OPTS + ' -g ' + DOCKER_DATA_DIR + '"';

variable DOCKER_OLD_PACKAGE ?= false; 

