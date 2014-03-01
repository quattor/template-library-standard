template xen/auto_network;

##
## Template that generates/guesses the xen network values
## - Does not override defined values?
## 
## Generated variables: XEN_VIF_BRIDGE, XEN_UDHCP_DEV, XEN_NETWORK_BRIDGES
## 

##
## enable all network interfaces as a network device on the dom0
## this is needed for the multibridge setup
## Ideally these are defined so they can be used for guessing the coupling to bridges
## - relies on network component
include { 'components/network/config' };
"/system/network/interfaces" = {
    foreach(k;v;value("/hardware/cards/nic")){
        if(! exists(SELF[k])) {
            SELF[k] = nlist('bootproto','none');
        };
    };
    SELF;
};

##
## For all defined interfaces, make a bridge
## - Don't start one for bonding slaves
##
variable XEN_NETWORK_BRIDGES = {
    if (is_nlist(SELF)) {
        l = SELF;
    } else {
        l = nlist();
    };
    
    i=0;
    foreach(k;v;value("/system/network/interfaces")){
        br = "xenbr"+to_string(i);
                
        if((! exists(l[br])) && (! exists(v['master']))) {
            l[br]= nlist('netdev',k,'vifnum',i);
        };
        i = i+1;
    };
    
    l; 
};

## 
## Make a map between dom0 dev and bridge name
## internal variable
##
variable XEN_NETWORK_BRIDGES_DEV2BR_MAP = {
    l = nlist();
    foreach(k;v;XEN_NETWORK_BRIDGES) {
        if (exists(v['netdev'])) {
            l[v['netdev']] = k;
        } else if (match(k,'xenbr(\d+)')) {
            m = matches(k,'xenbr(\d+)');
            dev = "eth"+m[1];
            l[dev] = k;
        } else {
            ## euhm, not supported.
            error("XEN_NETWORK_BRIDGES_DEV2BR_MAP: Defined bridge "+k+" has no netdev defined and does not match xenb(\\d+) regexp.");
        };
    };
    
    l;
};

## 
## convert base10 to bin
##
function base10_to_bin = {
    name = 'base10_to_bin';
    if (ARGC != 1) {
        error(name+": requires only one argument");
    };
    d = to_long(ARGV[0]);
    ans = '';
    
    div = d/2; 
    mod = d%2;
    while ((div+mod) > 0) {
        ans = to_string(mod) + ans;
        d = div;
        div = d/2;
        mod = d%2; 
    };
    
    return(ans);    
};

##
## convert an ip to a binary representation
##
function ip_to_bin = {
    name = 'ip_to_bin';
    if (ARGC != 1) {
        error(name+": requires only one argument");
    };
    ip = ARGV[0];
    if(is_ipv4(ip)) {
        result = matches(ip,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$');
        ans = '';
        i = 1;
        while(i <= 4) {
            ## add 256 for trailing 0s
            ans = ans + substr(base10_to_bin(256+to_long(result[i])),1,8);            
            i = i + 1;
        };
        return(ans);
    } else {
        error(name+": ip "+ip+" not supported (only ipv4 atm).");
    };
};

##
## the equivalent of route
## (well, sortof ;)
##
function which_dev_matches_ip = {
    name = 'which_dev_matches_ip';
    if (ARGC != 1) {
        error(name+": requires only one argument");
    };
    bin = ip_to_bin(ARGV[0]);
    
    foreach(k;v;value("/system/network/interfaces")){
        ## get all the ip/netmasks,routes,aliases
        ## try which one fits 
        ## - first hit is answer
        ## - (default) gateway is useless
        ##   dhcp requests are not routed
        ## - routing gateways are also useless 
        ##   imagine a direct route from dom0 to domU through private network exists on dom0
        ##   route add -host domu.public gw domU.private
        ##   this will never work unless the dom0 is the aii and/or profile server
        l = list();
        
        ## ipaddress
        if (exists(v['ip'])) {
            l[length(l)]=list(v['ip'],v['netmask']);
        };
        
        ## routes
        if (exists(v['route'])) {
            foreach(k2;v2;v['route']) {
                if (!exists(v2['gateway'])) {
                    if (exists(v2['netmask'])) {
                        l[length(l)]=list(v2['address'],v2['netmask']);
                    } else {
                        l[length(l)]=list(v2['address'],'255.255.255.255');
                    };
                };
            };
        };
        
        ## aliases
        if (exists(v['aliases'])) {
            foreach(k2;v2;v['aliases']) {
                l[length(l)] = list(v2['ip'],v2['netmask']);
            };
        };

        
        foreach(k3;v3;l) {
            b = ip_to_bin(v3[0]);
            mask = ip_to_bin(v3[1]);
            m = matches(mask,"^1+");
            if (substr(bin,0,length(m[0])) == substr(b,0,length(m[0]))) {
                return(k);
            };
        };
        
    };
    
    return('');            
};

##
## Map VM vif interfaces to bridges
## - requires domU to have network defined
## - requires dom0 to have network ranges/routes defined (if not really used, set proto = none)
## - so only the configured interfaces will have correct setting (since configure_guests uses /hardware/cards/nic)
##
variable XEN_VIF_BRIDGE = {
    foreach(i;vm;XEN_GUESTS) {
        if(!exists(SELF[vm])) {
            SELF[vm] = nlist();
        };
        foreach(k;v;value("//"+XEN_PROFILE_PREFIX+vm+"/system/network/interfaces")){
            if(!exists(SELF[vm][k])) {
                ## boot proto must be static
                ## for dhcp, only way to guess it would through be hostname+domainname?
                ## - not even that (eg multiple interfaces with dhcp proto)
                ## so no dhcp support for now
                if ((!exists(v['proto'])) || v['proto'] == 'static') {
                    d = which_dev_matches_ip(v['ip']);
                    if (length(d) >0) {
                        if (exists(XEN_NETWORK_BRIDGES_DEV2BR_MAP[d])) {
                            SELF[vm][k] = XEN_NETWORK_BRIDGES_DEV2BR_MAP[d];
                        };
                    };
                };
            };
        };
    };
    SELF;
};


##
## Set XEN_UDHCP_DEV
## - isn't this always the boot_nic of the dom0?
## - no. it needs to be a configured device (eg boning on the bootnic breaks it)
variable XEN_UDHCP_DEV = {
    foreach(i;vm;XEN_GUESTS) {
        if(!exists(SELF[vm])) {
             dev = boot_nic();
             res = dev;
             interfaces = value("/system/network/interfaces/");
             if (exists(interfaces[dev])) {
                if(exists(interfaces[dev]['master'])) {
                    res = interfaces[dev]['master'];
                };
             } else {
                ## this will never work.
                error("XEN_UDHCP_DEV for vm "+vm+": boot_nic "+dev+" is not defined in /system/network/interfaces.");
             };
             
             SELF[vm] = res;
        };
    };
    SELF;
};