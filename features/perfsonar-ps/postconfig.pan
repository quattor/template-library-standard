# This template installs a script that does what is normally executed through
# Kickstart postinsall in standard perfSONAR NetInstall method.
# TODO : use standard configuration modules when possible

unique template features/perfsonar-ps/postconfig;


variable PERFSONAR_POSTCONFIG_SCRIPT = '/var/quattor/script/perfsonar-postconfig';

include { 'components/filecopy/config' };

variable CONTENTS = <<SCRIPT_END;
#######################
# Setup a redirect so that if clients go to "http://[host]/", they get
# redirected to "http://[host]/toolkit". this isn't done in the rpm so that
# users who just install the rpm don't have their root web url taken away.
#######################
cat > /etc/httpd/conf.d/toolkit_root_redirect.conf <<EOF
# Redirects requests to "/" to "/toolkit". It's done in this strange way to
# avoid confusing people who enter an IP address and would get redirected to
# the hostname, or vice versa.
RewriteEngine     on
RewriteCond       %{HTTP_HOST} =""
RewriteRule       ^/$    http://%{SERVER_ADDR}/toolkit/

RewriteCond       %{HTTP_HOST} !=""
RewriteRule       ^/$    http://%{HTTP_HOST}/toolkit/
EOF

#######################
# Setup a redirect so that if clients go to "https://[host]/", they get
# redirected to "https://[host]/toolkit". this isn't done in the rpm so that
# users who just install the rpm don't have their root web url taken away.
#######################
sed -i 's|</VirtualHost>|RewriteEngine on\nRewriteOptions Inherit\n</VirtualHost>|g' /etc/httpd/conf.d/ssl.conf

#######################
# Disable weak SSL ciphers
#######################
sed -i 's|SSLProtocol.*|SSLProtocol -ALL +SSLv3 +TLSv1|g' /etc/httpd/conf.d/ssl.conf
sed -i 's|SSLCipherSuite.*|SSLCipherSuite ALL:!aNULL:!ADH:!DH:!EDH:!eNULL:-LOW:!EXP:RC4+RSA:+HIGH:-MEDIUM|g'  /etc/httpd/conf.d/ssl.conf

#######################
# Enable the Internet2-web100_kernel repository
#######################
sed -i -e 's|enabled.*=.*|enabled = 1|' /etc/yum.repos.d/Internet2-web100_kernel.repo

#######################
# Disable zeroconf route
#######################
cat >> /etc/sysconfig/network <<EOF
NOZEROCONF=yes
EOF

#######################
# Disable MySQL network access, and symlink access
#######################
cat > /etc/my.cnf <<EOF
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Default to using old password format for compatibility with mysql 3.x
# clients (those using the mysqlclient10 compatibility package).
old_passwords=1
skip-networking

# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
symbolic-links=0

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF

#######################
# Override the default owampd.conf to set the disk limit to 1G from the default
# of 10M
#######################
cat >/etc/owampd/owampd.limits <<EOF
limit root with delete_on_fetch=on, bandwidth=0, disk=0
limit regular with delete_on_fetch=on, parent=root, bandwidth=1000000, disk=1073741824, allow_open_mode=on
limit jail with parent=root, bandwidth=1, disk=1, allow_open_mode=off
assign default regular
EOF

#######################
# Make sure the owamp/bwctl output (set to syslog's local5) goes to a specific
# log file instead of /var/log/messages
#######################

# Make sure that bwctl is outputting to the syslog 'local5' facility. This is
# the default for owamp.
cat >>/etc/bwctld/bwctld.conf <<EOF
facility        local5
EOF

cat >>/etc/syslog.conf <<EOF
# Save bwctl and owamp messages to /var/log/perfsonar/owamp_bwctl.log
local5.*                                                /var/log/perfsonar/owamp_bwctl.log
EOF

#######################
# Override the default ntp.conf with one containing non-'pool' NTP servers
#######################
cat >/etc/ntp.conf <<EOF
logfile /var/log/ntpd
driftfile /var/lib/ntp/ntp.drift
statsdir  /var/lib/ntp/
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

# You should have at least 4 NTP servers

server owamp.chic.net.internet2.edu iburst
server owamp.hous.net.internet2.edu iburst
server owamp.losa.net.internet2.edu iburst
server owamp.newy.net.internet2.edu iburst
server chronos.es.net iburst
server saturn.es.net iburst
EOF

#######################
# Disable showing that PHP is installed on the server (see
# http://seclists.org/webappsec/2004/q4/324 for why)
#######################
sed -i 's|expose_php *=.*|expose_php = Off|' /etc/php.ini

#######################
# Make sure that the wheel group can use sudo
#######################
echo "%wheel        ALL=(ALL)       ALL" >> /etc/sudoers
SCRIPT_END


# Install the script and set it to run if modified
'/software/components/filecopy/services' = {
  SELF[escape(PERFSONAR_POSTCONFIG_SCRIPT) ] = nlist("config", CONTENTS,
                                                     "perms", "0755",
                                                     "owner", "root",
                                                     "restart", PERFSONAR_POSTCONFIG_SCRIPT,
                                                    );
  SELF;
};


