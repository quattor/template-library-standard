unique template features/frontier/config;

include 'features/frontier/rpms';

variable FRONTIER_LOCAL_NET ?= list();
variable FRONTIER_LOCAL_NET = push('127.0.0.1/32');
variable FRONTIER_HOST_MONITOR ?= list();
variable FRONTIER_HOST_MONITOR = push('127.0.0.1/32');
variable FRONTIER_CACHE_MEM ?= "128 MB";
variable FRONTIER_CACHE_DIR ?= '10000';

variable FRONTIER_LOCAL_NET_STRING ?= {
    tmp = "";
    foreach (k; v; FRONTIER_LOCAL_NET) {
        tmp = tmp + " " + v + " ";
    };
    tmp
};

variable FRONTIER_HOST_MONITOR_STRING ?= {
    tmp = "";
    foreach (k; v; FRONTIER_HOST_MONITOR) {
        tmp = tmp + " " + v + " ";
    };
    tmp
};

include 'components/filecopy/config';
'/software/components/filecopy/services/{/etc/squid/customize.sh}' = dict(
    'config', format(
        file_contents('features/frontier/customized.sh.file'),
        FRONTIER_LOCAL_NET_STRING,
        FRONTIER_HOST_MONITOR_STRING,
        FRONTIER_CACHE_MEM,
        FRONTIER_CACHE_DIR,
    ),
    'restart', 'service frontier-squid reload',
    'perms', '0644',
);

include 'components/chkconfig/config';

'/software/components/chkconfig/service/frontier-squid/on' = "";
'/software/components/chkconfig/service/frontier-squid/startstop' = true;
