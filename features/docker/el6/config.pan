unique template features/docker/el6/config;

# DOCKER_OLD_PACKAGE: deprecated, use DOCKER_PACKAGE instead
variable DOCKER_OLD_PACKAGE ?= false;

@{
descr = name of the Docker package
values = string
default = docker-engine
required = No
}
variable DOCKER_PACKAGE ?= if ( DOCKER_OLD_PACKAGE ) {
                               'docker-io'
                           } else {
                               'docker-engine'
                           };


# Add package
include {'components/spma/config'};
'/software/packages/' = pkg_repl(DOCKER_PACKAGE);

