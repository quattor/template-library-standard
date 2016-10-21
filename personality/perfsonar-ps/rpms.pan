unique template personality/perfsonar-ps/rpms;

# perfSonar and related mandatory tools
'/software/packages' = {
    pkg_repl('perfsonar-testpoint');
    pkg_repl('perfsonar-toolkit-servicewatcher');
    SELF;
};
