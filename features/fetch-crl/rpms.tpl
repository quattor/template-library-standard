unique template features/fetch-crl/rpms;

variable FETCH_CRL_RPM_NAME ?= 'fetch-crl';
variable FETCH_CRL_VERSION ?= {
    if (match(OS_VERSION_PARAMS['major'], '[es]l6')) {
        '3.0.8-1.el6';
    } else if (match(OS_VERSION_PARAMS['major'], '[es]l5')) {
        '2.8.5-1.el5';
    } else if (OS_VERSION_PARAMS['major'] == 'fedora14') {
        '2.8.5-1.el5';
    } else {
        '2.7.0-2';
    };
};
	
'/software/packages' = {
    debug(FULL_HOSTNAME+': adding fetch-crl version '+FETCH_CRL_VERSION+' (OS:'+OS_VERSION_PARAMS['major']+', RPM name:'+FETCH_CRL_RPM_NAME+')');
    pkg_repl(FETCH_CRL_RPM_NAME, FETCH_CRL_VERSION, 'noarch');
};
