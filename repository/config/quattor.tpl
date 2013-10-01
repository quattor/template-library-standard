#######################################################################
#
# Standard repositories to use for Quattor configuration based on
# Quattor release.
#
#######################################################################
 
unique template repository/config/quattor;
 
include { 'quattor/functions/repository' };

# Ordered list of repository to load
variable QUATTOR_REPOSITORY_LIST ?= if ( is_defined(QUATTOR_RELEASE) ) {
                                     debug("Adding repository for Quattor release "+QUATTOR_RELEASE);
                                     list('quattor_'+QUATTOR_RELEASE,'quattor_externals','quattor_components');
                                   } else {
                                     debug("Quattor release undefined: adding repository for legacy Quattor");
                                     list('quattor_sl', 'quattor_components');
                                   };

'/software/repositories' = add_repositories(QUATTOR_REPOSITORY_LIST);
