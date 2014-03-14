unique template features/pakiti/server;

variable PAKITI_AUTH ?= true;
variable PAKITI_USERS ?= list(
# '',
);

variable PAKITI_VIRTUAL_HOST ?= PAKITI_SERVER;
variable PAKITI_HOSTCERT ?= '/etc/grid-security/hostcert.pem';
variable PAKITI_HOSTKEY ?= '/etc/grid-security/hostkey.pem';
variable PAKITI_DOCROOT ?= '/var/lib/pakiti2/www';
variable PAKITI_USERS_FILE ?= '/var/lib/pakiti/users';


include { if_exists('config/pakiti/server/config') };
include { "components/filecopy/config" };

# Specific authentification part
variable CONFIG_AUTH = "";
#variable CONFIG_AUTH = '<Directory "'+PAKITI_DOCROOT + '">'+"\n";
variable CONFIG_AUTH = CONFIG_AUTH + "SSLVerifyClient      require\n";
variable CONFIG_AUTH = CONFIG_AUTH + "SSLVerifyDepth       5\n";
variable CONFIG_AUTH = CONFIG_AUTH + "SSLCACertificatePath " + PAKITI_CA_PATH +"\n";
variable CONFIG_AUTH = CONFIG_AUTH + "SSLOptions           +FakeBasicAuth\n";
variable CONFIG_AUTH = CONFIG_AUTH + "AuthName             "+'"'+"Pakiti: YOUR CERTIFICATE MUST BE REGISTERED"+'"'+"\n";
variable CONFIG_AUTH = CONFIG_AUTH + "AuthType             Basic\n";
variable CONFIG_AUTH = CONFIG_AUTH + "require              valid-user\n";
variable CONFIG_AUTH = CONFIG_AUTH + "SSLUserName SSL_CLIENT_S_DN\n";
variable CONFIG_AUTH = CONFIG_AUTH + "AuthUserFile         "+ PAKITI_USERS_FILE +"\n";
#variable CONFIG_AUTH = CONFIG_AUTH + "SSLRequireSSL\n";
#variable CONFIG_AUTH = CONFIG_AUTH + "Options -All\n";
#variable CONFIG_AUTH = CONFIG_AUTH + "AllowOverride None\n";
#variable CONFIG_AUTH = CONFIG_AUTH + "DirectoryIndex index.php\n";
#variable CONFIG_AUTH = CONFIG_AUTH + "</Directory>\n";

#HTTP configuration
variable CONFIG= if ( ( PAKITI_SERVER_PORT != "443") ) {
	"Listen " + PAKITI_SERVER_PORT + "\n\n"; #must listen on given port
} else {
	"";
};

variable CONFIG= CONFIG + "<VirtualHost " + PAKITI_VIRTUAL_HOST + ":" + PAKITI_SERVER_PORT +">\n" + <<EOF;
SSLEngine on
SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP
EOF

variable CONFIG = CONFIG + "SSLCertificateKeyFile "+ PAKITI_HOSTKEY + "\n";
variable CONFIG = CONFIG + "SSLCertificateFile " + PAKITI_HOSTCERT + "\n";
variable CONFIG = CONFIG + "SSLCACertificatePath "+ PAKITI_CA_PATH + "\n";

variable CONFIG = CONFIG + "DocumentRoot "+ PAKITI_DOCROOT+"/\n";
variable CONFIG = CONFIG + <<EOF;
ErrorLog logs/pakiti-error
CustomLog logs/pakiti-access common
EOF

variable CONFIG = CONFIG + 'Alias /feed "'+ PAKITI_DOCROOT +'/feed"'+"\n";

variable CONFIG = CONFIG + '<Directory "'+ PAKITI_DOCROOT + '/feed">'+"\n";
variable CONFIG = CONFIG + <<EOF;
  SSLRequireSSL
  Options -All
  AllowOverride None
  DirectoryIndex index.php
</Directory>
EOF

variable CONFIG = CONFIG + 'Alias /link "' + PAKITI_DOCROOT + '/link"'+"\n";
variable CONFIG = CONFIG + '<Directory "' + PAKITI_DOCROOT + '/link">'+"\n";
variable CONFIG = CONFIG + <<EOF;
  SSLRequireSSL
  Options +FollowSymLinks
  AllowOverride None
  Order allow,deny
  Allow from all
  DirectoryIndex index.php
</Directory>
EOF

variable CONFIG = CONFIG + '<Directory "' + PAKITI_DOCROOT + '/pakiti">'+"\n";
variable CONFIG = if ( PAKITI_AUTH ) {
        CONFIG + CONFIG_AUTH
} else {
        CONFIG
};
variable CONFIG = CONFIG + <<EOF;
  # Restrict access to this directory by your own auth mech, authorization can be made by the Pakiti itself
  SSLRequireSSL
  Options +FollowSymLinks
  AllowOverride None
  Order allow,deny
  Allow from all
  DirectoryIndex index.php
</Directory>

</VirtualHost>
EOF

"/software/components/filecopy/services" =
 npush(escape("/etc/httpd/conf.quattor/pakiti.conf"),
       nlist("config",CONFIG,
             "perms","0644",'restart', 'service httpd restart')
       );

variable CONFIG = {
	contents = "";
	ok = first(PAKITI_USERS,key,value);
        while(ok) {
                contents = contents + value + ":xxj31ZMTZzkVA\n";
                ok = next(PAKITI_USERS,key,value);
        };
	contents;
};
"/software/components/filecopy/services" =
 npush(escape(PAKITI_USERS_FILE),
       nlist("config",CONFIG,
             "perms","0644")
       );

include { 'components/symlink/config' };

"/software/components/symlink/links" =
    push(nlist( "name", "/etc/httpd/conf.d/pakiti.conf",
                 "target","/etc/httpd/conf.quattor/pakiti.conf",
                "replace",  nlist("all","yes","link", "yes")
              )
         );
 
 
##           
##Pakiti Server config
##

variable CONFIG = <<EOF;
# Configuration file for the Pakti web interface.

# Set the parameters for connecting to
# the Pakiti database.

[mysql]
EOF

variable CONFIG = CONFIG + "hostname = " + PAKITI_DB_HOST + "\n";
variable CONFIG = CONFIG + "dbname   = " + PAKITI_DB_NAME+ "\n";
variable CONFIG = CONFIG + "username = " + PAKITI_DB_USER + "\n";
variable CONFIG = CONFIG + "password = " + PAKITI_DB_PASS + "\n";

variable CONFIG = CONFIG + "[webinterface]\n";
variable CONFIG = CONFIG + "# URL of your local Pakiti server\n";
variable CONFIG = CONFIG + "url = https://" + FULL_HOSTNAME + "\n"
	+ "title = " + PAKITI_TITLE + "\n" ;

"/software/components/filecopy/services" =
 npush(escape("/etc/pakiti2/pakiti2-server.conf"),
       nlist("config",CONFIG,
       		 "owner","apache",
             "perms","0600"));

include { 'components/chkconfig/config' };
"/software/components/chkconfig/service/pakiti2/on" = "";
"/software/components/chkconfig/service/pakiti2/startstop" = true;

#fix permissions of init script (otherwise, no OVAL update will be done)!
include { 'components/dirperm/config' };
"/software/components/dirperm/paths" =
 push(nlist(
  "path", "/etc/init.d/pakiti2",
  "owner", "root:root",
  "perm", "0775",
  "type", "f"
  )
 );

