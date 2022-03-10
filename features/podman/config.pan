unique template features/podman/config;

@{
desc = if true, enable the Podman API daemon
value = boolean
default = true
required = no
}
variable POADMAN_API_DAEMON_ENABLED ?= true;


# Add RPM
'/software/packages' = pkg_repl('podman');


# Enable Podman API daemon
include if ( POADMAN_API_DAEMON_ENABLED ) 'features/podman/api_daemon';
