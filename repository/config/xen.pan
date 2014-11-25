#######################################################################
#
# Standard repositories to use for Xen (OS/architecture dependent)
#
#######################################################################
 
unique template repository/config/xen;
 
include { 'quattor/functions/repository' };

# Ordered list of repository to load
variable XEN_REPOSITORY_LIST = list('xen');

'/software/repositories' = add_repositories(XEN_REPOSITORY_LIST);
