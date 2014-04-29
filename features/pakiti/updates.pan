# SPMA only

unique template features/pakiti/updates;

variable PAKITI_VERSION = '2.1.4-4';
'/software/packages'=pkg_ronly("pakiti-client",PAKITI_VERSION,"noarch");
'/software/packages'=pkg_ronly("pakiti-server",PAKITI_VERSION,"noarch");
'/software/packages'=pkg_ronly("pakiti-client-manual",PAKITI_VERSION,"noarch");
