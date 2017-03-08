unique template features/docker/config;

#Load the parameters
include {'features/docker/params'};

#Install the docker package
include {'components/spma/config'};

'/software/packages/' = if(DOCKER_OLD_PACKAGE){
  SELF[escape('docker-io')] = nlist();
  SELF;
}else{
  SELF[escape('docker-engine')] = nlist();
  SELF;
};

#Copy some needed files
include {'components/filecopy/config'};

prefix '/software/components/filecopy/services/';

'{/usr/bin/pipework}/config' = file_contents('features/docker/pipework');
'{/usr/bin/pipework}/perms' = '0755';


#Sysconfig for the docker service
include {'components/sysconfig/config'};

prefix '/software/components/sysconfig/files/docker';

'DOCKER_TMPDIR' = if(is_defined(DOCKER_DATA_DIR)){
  DOCKER_DATA_DIR + '/tmp';
}else{
  null
};
'other_args' = DOCKER_SRV_OPTS;

#Set the condor service to be running at boot
include {'components/chkconfig/config'};

prefix '/software/components/chkconfig/service/docker';

'on' = "";
'add' = true;
'startstop' = true;


#Setup the backup
include {if(is_defined(DOCKER_BACKUP) && DOCKER_BACKUP){'features/docker/backup'}};
