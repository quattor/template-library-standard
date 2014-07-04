#######################################################################
#
# Standard repositories to use for Quattor configuration based on
# Quattor release.
#
#######################################################################
 
unique template repository/config/quattor;
 
include { 'quattor/functions/repository' };

# Ordered list of repository to load
# QUATTOR_REPOSITORY_RELEASE allows to define the Quattor release repository to use, in case
# there is no repository specific to the release
variable QUATTOR_REPOSITORY_RELEASE ?= QUATTOR_RELEASE;
# First try a template specific to the release if it exists, else use a generic one
# for 14.6+ or the release specific one before.
@{
desc = repository template describing YUM repository to use for the Quattor release
values = a templane name with the 'repository/' namespace ommitted
default = generic repository template appropriate
required = no
}
variable QUATTOR_REPOSITORY_TEMPLATE ?= if ( is_defined(if_exists('repository/quattor_'+QUATTOR_REPOSITORY_RELEASE)) ) {
                                          'quattor_'+QUATTOR_REPOSITORY_RELEASE;
                                        };
variable QUATTOR_REPOSITORY_TEMPLATE ?= if ( is_defined(QUATTOR_RELEASE) && ((QUATTOR_RELEASE >= '15') || match(QUATTOR_RELEASE,'^14\.[1689]')) ) {
                                          if ( match(QUATTOR_RELEASE,'-rc\d+$') ) {
                                            'quattor_rc';
                                          } else {
                                            'quattor';
                                          };
                                        } else {
                                          'quattor_' + QUATTOR_REPOSITORY_RELEASE;
                                        };
variable QUATTOR_REPOSITORY_TEMPLATE ?= 'quattor_' + QUATTOR_REPOSITORY_RELEASE;
variable QUATTOR_REPOSITORY_LIST ?= if ( is_defined(QUATTOR_RELEASE) ) {
                                      if ( match(QUATTOR_RELEASE,'13\.1') && (QUATTOR_RELEASE != '13.12') ) {
                                        repos = list(QUATTOR_REPOSITORY_TEMPLATE,'quattor_externals','quattor_components');
                                      } else {
                                        repos = list(QUATTOR_REPOSITORY_TEMPLATE,'quattor_externals');
                                      };
                                      debug("Repositories added for Quattor release "+QUATTOR_RELEASE+": "+to_string(repos));
                                      repos;
                                    } else {
                                      error("Quattor release undefined: not supported anymore, define QUATTOR_RELEASE to a version >= 13.1");
                                    };

'/software/repositories' = add_repositories(QUATTOR_REPOSITORY_LIST);
