# This template uses 
#
# RESPONSIBLE: Stephen Childs <childss@cs.tcd.ie>

template xen/grub;


#title Scientific Linux SL (2.6.18-1.2835.slc4xen)
#        root (hd0,0)
#        kernel /xen.gz-2.6.18-1.2835.slc4 dom0_mem=200M
#        module /vmlinuz-2.6.18-1.2835.slc4xen ro root=LABEL=/ console=tty0
#        module /initrd-2.6.18-1.2835.slc4xen.img

function dev_from_block = {
    name = 'dev_from_block';
    if (ARGC != 1) {
        error(name+": requires only one argument");
    };
    block = to_string(ARGV[0]);
    
    if (match(block,"^(md|partitions)/(.*)")) {
        res=matches(block,"^(md|partitions)/(.*)");
        return("/dev/"+res[2]);
    } else {
        error(name+": not supported "+block)
    };
    
};

variable XEN_DOM0_ROOT_DEVICE ?= {
    l = value("/system/filesystems");
    foreach(i;fs;l) {
        if (exists(fs['mountpoint']) && fs['mountpoint'] == '/') {
            if(exists(fs['block_device'])) {
                return(dev_from_block(fs['block_device']));
            } else {
                error("XEN_DOM0_ROOT_DEVICE: found mountpoint /, but no block_device");
            };
        } 
    };
    ## if you get here, it wasn't found
    error("XEN_DOM0_ROOT_DEVICE: no mountpoint / found. Please set XEN_DOM0_ROOT_DEVICE manually.");
};
variable XEN_DOM0_MEM ?= "400M";


"/software/components/grub/kernels" = push(
               nlist("multiboot", "/xen.gz-"+XEN_LINUX_VERSION,
                     "mbargs", "dom0_mem="+XEN_DOM0_MEM,
                     "title", "Xen "+XEN_VERSION+" / XenLinux "+XEN_LINUX_VERSION,
                     "kernelpath", "/vmlinuz-"+XEN_LINUX_VERSION+"xen",
                     "kernelargs", "max_loop=128 root="+XEN_DOM0_ROOT_DEVICE+" ro console=tty0",
                     "initrd", "/initrd-"+XEN_LINUX_VERSION+"xen.img" ));

