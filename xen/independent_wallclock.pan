template xen/independent_wallclock;
include { 'components/sysctl/config' };
# set independent wallclock
"/software/components/sysctl/variables"= npush("xen.independent_wallclock","1");

