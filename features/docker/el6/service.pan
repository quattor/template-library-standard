unique template features/docker/el6/service;

#Sysconfig for the docker service
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


