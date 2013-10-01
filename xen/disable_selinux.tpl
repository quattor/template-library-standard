template xen/disable_selinux;

variable XEN_DISABLE_SELINUX?=false;

# disable SELINUX as it doesn't work well with Xen
variable SELINUX_CONFIG= <<EOF;
SELINUX=disabled
SELINUXTYPE=targeted
EOF
#include { 'components/filecopy/config' };
#"/software/components/filecopy/services" = if (XEN_DISABLE_SELINUX) {
#    npush(escape("/etc/selinux/config"),
#        nlist("config",SELINUX_CONFIG,
#              "owner", "root",
#              "perms","0644"));
#  }
#  else {
#   SELF;
#  };
