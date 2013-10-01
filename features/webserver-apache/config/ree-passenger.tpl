unique template features/webserver-apache/config/ree-passenger;

variable REE_PASSENGER_CONF = <<EOF;
LoadModule passenger_module /opt/ree/lib/ruby/gems/1.8/gems/passenger-2.2.11/ext/apache2/mod_passenger.so
PassengerRoot /opt/ree/lib/ruby/gems/1.8/gems/passenger-2.2.11
PassengerRuby /opt/ree/bin/ruby
EOF

variable REE_PROFILE = <<EOF;
#!/bin/sh
export PATH=/opt/ree/bin:$PATH
EOF

include {'components/filecopy/config'};
"/software/components/filecopy/services" = if (index("ree-passenger",WEB_SERVER_MODULES) != -1 ) {
  npush(escape("/etc/httpd/conf.d/passenger.conf"), nlist(
    "config",REE_PASSENGER_CONF,
    "perms", "0644",
    "restart","passenger-install-apache2-module -a",
  ),
  escape("/etc/profile.d/ruby-enterprise.sh"), nlist(
    "config",REE_PROFILE,
    "perms", "0755",
  ));
} else {
  SELF;
};