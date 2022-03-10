unique template features/docker/el8/daemon_config;

@{
descr = daemon.json content
values = string
default =  built using DOCKER_SRV_OPTS
required = No
}
variable DOCKER_DAEMON_CFG_CONTENT ?= {
    txt = "{\n";
    i = 1;
    foreach (name; value; DOCKER_SRV_OPTS) {
        if ( i < length(DOCKER_SRV_OPTS) ) {
            sep = ",\n";
        } else {
            sep = "\n";
        };
        if(is_string(value)){
            txt = txt + format('"%s": "%s"%s', name, value, sep);
        }else{
            txt = txt + format('"%s": %s%s', name, value, sep);
        };
        i = i + 1;
    };
    txt = txt + "}\n";
    txt;
};

# Create daemon config file
include 'components/filecopy/config';
prefix '/software/components/filecopy/services';
'{/etc/docker/daemon.json}' =  dict("config", DOCKER_DAEMON_CFG_CONTENT,
                                    "perms", "0644",
                                    "restart", "systemctl restart docker",
                                    );


