unique template features/webserver-apache/service;

variable WEB_SERVER_MODULES?=list();
variable VHOSTS?=nlist();
variable DEFAULT_WEB_PORT?=80;
variable DEFAULT_WEB_SSL?=false;

# Add the packages from OS
include { 'features/webserver-apache/config' };

include { 'features/webserver-apache/config/default-vhost' };

include { if (index("ree-passenger",WEB_SERVER_MODULES) != -1 ) 'features/webserver-apache/config/ree-passenger' };

include {'components/filecopy/config'};
"/software/components/filecopy/services" = {
  if ( is_nlist(SELF) ) {
    web_apps = SELF;
  } else {
    web_apps = nlist();
  };
  ok = first(VHOSTS, i, web_app);
  while (ok) {
    if ( is_nlist(web_app) ) {
      web_app_config = web_app['config'];
    } else {
      web_app_config = web_app;
    };
    web_apps[escape("/etc/httpd/conf.d/vhost_"+i+".conf")] = nlist(
      "config",web_app_config,
      "perms", "0644",
      "restart", "service httpd reload",
    );
    ok = next(VHOSTS, i, web_app);
  };
  return(web_apps);
};

# ---------------------------------------------------------------------------- 
# chkconfig
# Ensure httpd is running.
# ---------------------------------------------------------------------------- 
include { 'components/chkconfig/config' };

"/software/components/chkconfig/service/httpd/on" = ""; 
"/software/components/chkconfig/service/httpd/startstop" = true; 
