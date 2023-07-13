declaration template os/network/network_manager_schema;

type network_manager_config_main = {
    'dns' ? choice('none')
};

type network_manager_configuration = {
    'main' : network_manager_config_main
};
