template xen/host/config;

include { 'components/xen/config' };

variable XEN_BOOT_DEVICE ?= undef; # in future, extract automatically?
variable XEN_VG ?= undef;          # in future, extract automatically?


variable XEN_CREATE_FILESYSTEMS ?= false;
variable XEN_CREATE_DOMAINS ?= false;

"/software/components/xen/create_filesystems"=XEN_CREATE_FILESYSTEMS;
"/software/components/xen/create_domains"=XEN_CREATE_DOMAINS;

include { 'xen/configure_guests' };

# disable SELINUX if XEN_DISABLE_SELINUX is defined
#include { 'xen/disable_selinux' };

include { 'rpms/xen/host' };

# linux and Xen versions needed by grub config are set
# in the OS-specific package includes so this comes last
include { 'xen/grub' };
