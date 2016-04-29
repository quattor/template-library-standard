unique template features/docker/backup;

variable DOCKER_BACKUP_DIR?="/backup";

variable DOCKER_BACKUP_MAIL_OK=if(is_defined(DOCKER_BACKUP_MAIL_OK)){"-mailok "+SELF}else{""};

variable DOCKER_BACKUP_MAIL_ERR=if(is_defined(DOCKER_BACKUP_MAIL_ERR)){"-mailerr "+SELF}else{""};

variable DOCKER_BACKUP_COMMAND?="/usr/sbin/backup_docker_data -dir "+DOCKER_BACKUP_DIR+" "+DOCKER_BACKUP_MAIL_OK+" "+DOCKER_BACKUP_MAIL_ERR;

variable DOCKER_BACKUP_FREQUENCY?="30 11 * * *";

include {'components/filecopy/config'};

'/software/components/filecopy/services/{/usr/sbin/backup_docker_data}' = nlist(
                            "config", file_contents('features/docker/backup_docker_data'),
                            "owner", "root",
                            "perms","0755",
                          );

include {'components/cron/config'};

"/software/components/cron/entries" = {
        SELF[length(SELF)]=nlist(
                        "name","backup_docker_data",
                        "frequency", DOCKER_BACKUP_FREQUENCY,
                        'command', DOCKER_BACKUP_COMMAND,
                        );
        SELF;
};

