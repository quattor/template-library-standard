template xen/guest/config;

# OS-specific setup
variable XEN_OS_CONFIG = { if (exists("config/os/xen/guest")) {"config/os/xen/guest"} else {null}; };
include {XEN_OS_CONFIG};

"/system/kernel/version" = if ( exists(OS_VERSION_PARAMS) && is_defined(OS_VERSION_PARAMS) ) {
                              tok = matches(OS_VERSION_PARAMS['version'],'^sl(.)..$');
                              sl_ver = tok[1];
                              if (sl_ver == "4") {
                                return (KERNEL_VERSION_NUM+"xenU");
                              } else {
                                return (KERNEL_VERSION_NUM+"xen");
                              }
                            } else {
                              error('No SL version!');
                              return(SELF);
                            };

# set up pxelinux
"/system/aii/nbp/pxelinux/label" = { return(SELF+" Xen"); };
"/system/aii/nbp/pxelinux/kernel" = { return(AII_NBP_ROOT+"_xen"+"/vmlinuz"); };
"/system/aii/nbp/pxelinux/initrd" = { return(AII_NBP_ROOT+"_xen"+"/initrd.img"); };

variable XEN_INDEPENDENT_WALLCLOCK ?= false;
variable XEN_INDEPENDENT_WALLCLOCK_CONFIG = { if (XEN_INDEPENDENT_WALLCLOCK) {"xen/independent_wallclock"} else {null}; };
include {XEN_INDEPENDENT_WALLCLOCK_CONFIG};

variable XEN_DEPENDENT_WALLCLOCK_CONFIG = { if (!XEN_INDEPENDENT_WALLCLOCK) {"xen/dependent_wallclock"} else {null}; };
include {XEN_DEPENDENT_WALLCLOCK_CONFIG};

# include RPMs
include { 'rpms/xen/guest' };

# disable SELINUX if XEN_DISABLE_SELINUX is defined
#include { 'xen/disable_selinux' };

# iterate through XEN_DB to find host
"/hardware/location" = {

    myhost="";
    if (exists(XEN_DB)) {
    foreach (host; guestlist; XEN_DB) {
        debug("host: "+host);
        foreach(index; guest; guestlist) {

            if (guest == FULL_HOSTNAME) {

                if (myhost == "") {
                    myhost=host;
                } else if (myhost != host) {
                    error("Guest "+FULL_HOSTNAME+" defined on >1 host: "+myhost+", "+host);

                };
            };

        };
    };
#    if (myhost == "") {
#        error ("No host found for guest "+FULL_HOSTNAME);
#    };
};
    myhost;
};

"/hardware/cards/nic" = { if (exists(XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]) && exists(XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]["nic"])) {XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]["nic"]} else {SELF}; };
"/hardware/harddisks" = { if (exists(XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]) && exists(XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]["harddisks"])) {XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]["harddisks"]} else {SELF}; };
"/hardware/ram/0/size" = { if (exists(XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]) && exists(XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]["ram_size"])) {XEN_GUESTS_MACHINE_DB[FULL_HOSTNAME]["ram_size"]} else {SELF}; };
