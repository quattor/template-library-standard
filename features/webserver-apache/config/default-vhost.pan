unique template features/webserver-apache/config/default-vhost;

variable DEFAULT_VHOST_CONFIG = {
  if (index("ssl",WEB_SERVER_MODULES) != -1 ) {
    config = "NameVirtualHost SERVERIP:80 \n\
NameVirtualHost SERVERIP:443 \n\
<VirtualHost SERVERIP:80> \n\
  DocumentRoot /var/www/html \n\
</VirtualHost> \n\
<VirtualHost SERVERIP:443> \n\
  SSLCertificateFile /etc/pki/tls/certs/localhost.crt \n\
  SSLCertificateKeyFile /etc/pki/tls/private/localhost.key \n\
  SSLCACertificatePath /etc/grid-security/certificates/ \n\
  SSLEngine on \n\
  SSLCipherSuite ALL:!DHE-RSA-AES256-SHA:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL\n\
  DocumentRoot /var/www/html \n\
</VirtualHost>\n";
  } else {
    config = "NameVirtualHost SERVERIP:80 \n\
<VirtualHost SERVERIP:80> \n\
  DocumentRoot /var/www/html \n\
</VirtualHost>\n";
  };
  return (config);
};

variable DEFAULT_VHOST_CONFIG = replace('SERVERIP',DB_IP[escape(FULL_HOSTNAME)],DEFAULT_VHOST_CONFIG);

"/software/components/filecopy/services" = npush(escape("/etc/httpd/conf.d/default.conf"), nlist(
  "config",DEFAULT_VHOST_CONFIG,
  "perms", "0644",
));