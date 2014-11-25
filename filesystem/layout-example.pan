# Filesystem layout template
# Can be used as a starting point for a site specific template

template filesystem/layout-example;

include { 'quattor/functions/filesystem' };

variable DISK_SUP_DEV ?= {
  if (exists("/hardware/harddisks/sdb")) {
    return("sdb");
  } else if (exists("/hardware/harddisks/hdb")) {
    return("hdb");
  } else if (exists("/hardware/harddisks/xvdb")) {
    return("xvdb");
  } else {
    undef;
  };
};

#variable DISK_SUP_PARTS ?= list('lvm');
variable DISK_SUP_PARTS ?= list('');

# Scratch volume is a generic volume whose mount point can be changed according to site needs
variable DISK_SCRATCH_SIZE ?= 0;
variable DISK_SCRATCH_LOGVOL ?= 'scratch';
variable DISK_SCRATCH_MOUNTPOINT ?= '/scratch';;
#variable DISK_SCRATCH_SIZE ?= if ( is_defined(DISK_SUP_DEV) ) {
#                               -1;
#                             } else {
#                               0;
#                             };

# Allow to redefine homevol mount point
variable DISK_HOME_SIZE ?= 0*GB;
variable DISK_HOME_MOUNTPOINT ?= '/home';

variable DISK_OPT_SIZE ?= 2*GB;
variable DISK_ROOT_SIZE ?= 1*GB;
variable DISK_SWAREAS_SIZE ?= 0*GB;
variable DISK_TMP_SIZE ?= 1*GB;
variable DISK_USR_SIZE ?= 5*GB;
variable DISK_VAR_SIZE ?= if ( DISK_SCRATCH_SIZE == 0 ) {
                                 -1;
                               } else {
                                 10*GB;
                               };


# Define default layout customizations for gLite nodes
variable DISK_VOLUME_PARAMS = filesystem_layout_mod(nlist(
  'home',          nlist('size', DISK_HOME_SIZE,
                         'mountpoint', DISK_HOME_MOUNTPOINT),
  'opt',           nlist('size', DISK_OPT_SIZE),
  'root',          nlist('size', DISK_ROOT_SIZE),
  'scratch',       nlist('size', DISK_SCRATCH_SIZE,
                         'type', 'lvm',
                         'mountpoint', DISK_SCRATCH_MOUNTPOINT,
                         'volgroup', 'vg.01',
                         'device', DISK_SCRATCH_LOGVOL),
  'swareas',        nlist('size', DISK_SWAREAS_SIZE),
  'tmp',           nlist('size', DISK_TMP_SIZE),
  'usr',           nlist('size', DISK_USR_SIZE),
  'var',           nlist('size', DISK_VAR_SIZE),
));


# Redefine swap size if explicitly defined with variable NODE_SWAP_SIZE
variable DISK_VOLUME_PARAMS = {
  if ( is_defined(NODE_SWAP_SIZE) ) {
    filesystem_layout_mod(nlist('swap', nlist('size', NODE_SWAP_SIZE)));
  } else {
    SELF;
  };
};
