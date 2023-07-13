unique template os/network/network_manager;

include 'os/network/network_manager_schema';

include 'components/metaconfig/config';
prefix '/software/components/metaconfig/services/{/etc/NetworkManager/conf.d/99-quattor.conf}';
'module' = 'tiny';
bind '/software/components/metaconfig/services/{/etc/NetworkManager/conf.d/99-quattor.conf}/contents' =
    network_manager_configuration;

# Disable management of resolv.conf by NM
'contents/main/dns' = 'none';
