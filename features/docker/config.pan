unique template features/docker/config;

variable DOCKER_BACKUP?=false;
variable DOCKER_PIPEWORK?=false;

include {'features/docker/service'};

include {if(DOCKER_BACKUP){'features/docker/backup'}};

include {if(DOCKER_PIPEWORK){'features/docker/pipework'}};
