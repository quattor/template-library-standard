template xen/configure_guests;

variable XEN_BOOTLOADER_DEFAULT ?="/usr/bin/pygrub";
variable XEN_BOOTARGS_DEFAULT ?= "";
variable XEN_PROFILE_PREFIX?="";
# set up default set of VMs for a mini-gateway: most parameters
# are extracted from the machines' own profiles, so it is important
# that the hardware and FS configuration are set up correctly

variable XEN_GUESTS ?= {
    res=list();
    debug(FULL_HOSTNAME+": Reading XEN_DB to get list of guests");    
    if (exists(XEN_DB) && exists(XEN_DB[FULL_HOSTNAME])) {
        res=XEN_DB[FULL_HOSTNAME];    
        foreach (key; value; res) {
            debug("xendb: guest: "+value);

        };

    };

    res;
};

include { 'xen/auto_network' };

"/software/components/xen/domains" ?= {

  result=nlist();

  i=0;

  while (i<length(XEN_GUESTS)) {
    vm=XEN_GUESTS[i];
    debug(FULL_HOSTNAME+": Configuring guest "+vm);
    options=nlist();

    if (exists(XEN_RAM) && is_defined(XEN_RAM)) {    
        xen_ram=XEN_RAM;

    }
    else {
        xen_ram=value("//"+XEN_PROFILE_PREFIX+vm+"/hardware/ram/0/size")/MB;      
    };
        
    # get first disk from /hardware
    first(value("//"+XEN_PROFILE_PREFIX+vm+"/hardware/harddisks"),mydisk,v);

    options['bootloader']=  if (exists(XEN_BOOTLOADER[vm])) {
        XEN_BOOTLOADER[vm];
        }
        else {
            XEN_BOOTLOADER_DEFAULT;
            };
    options["memory"]= xen_ram;
    options['name']=vm;
    options["vif"] = list();
    foreach(k;v;value("//"+XEN_PROFILE_PREFIX+vm+"/hardware/cards/nic")){
        txt="mac="+v['hwaddr'];
        if (exists(XEN_VIF_BRIDGE[vm]) && exists(XEN_VIF_BRIDGE[vm][k])) {
            txt = txt+",bridge="+XEN_VIF_BRIDGE[vm][k];
        };

        options["vif"][length(options["vif"])] = txt;
    };
    options['bootargs'] =  if (!exists(XEN_BOOTARGS[vm])) {
    options['vcpus'] = length( value("//"+XEN_PROFILE_PREFIX+vm+"/hardware/cpu"));
         if (match(options['bootloader'],"pypxeboot")) {
         "vif[0]";
         }
         else {
          XEN_BOOTARGS_DEFAULT;
         };
    } else {
        XEN_BOOTARGS[vm];
    };

    options["disk"]=list(nlist("type",'lvm',
                     "hostdevice",XEN_VG,
                     "hostvol",vm,
                     "guestdevice",mydisk,                    
                     "size", value("//"+XEN_PROFILE_PREFIX+vm+"/hardware/harddisks/"+mydisk+"/capacity"),
                     "rw",'w'));
    options["disk"][0]["create"]= if (XEN_CREATE_FILESYSTEMS) {true;} else {false;};

#    options['vfb']         = "['type=vnc,vncunused=1,vncdisplay=0']";



    result[vm]['options']=options;

    # set VM to auto-start
    result[vm]['auto']=true;


    i=i+1;
  };

  result;
};

# add configuration for multibridge, if any.
"/software/components/xen" = {
    if(length(XEN_NETWORK_BRIDGES) > 0) {
        SELF['network']['bridges'] = XEN_NETWORK_BRIDGES;
    };
    SELF;
};

