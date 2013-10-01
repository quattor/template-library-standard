template xen/dependent_wallclock;

#disable ntpd
"/software/components/chkconfig/service/ntpd"=nlist("off","");
"/software/components/chkconfig/service/ntpd/startstop" = true;
"/software/packages"=pkg_del("ncm-ntpd");
"/software/components/ntpd/active" = false;
"/software/components/ntpd/dispatch" = false;
