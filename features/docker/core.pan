unique template features/docker/core;

# Some docker dependencies are provided in extras repo
variable REPOSITORY_CENTOS_EXTRAS_ENABLED ?= true;

# OS dependent setup
include if ( OS_VERSION_PARAMS['family'] == 'el' ) {
            format('features/docker/el%s/config', OS_VERSION_PARAMS['majorversion']);
        } else {
            error('Docker configuration: unsupported OS version (%s)', OS_VERSION_PARAMS['major']);
        };

# Add Docker package (actual package name defined in OS variant)
include 'components/spma/config';
'/software/packages' = pkg_repl(DOCKER_PACKAGE);

# Start the docker service
include 'components/chkconfig/config';
prefix '/software/components/chkconfig/service/docker';
'on' = "";
'add' = true;
'startstop' = true;


