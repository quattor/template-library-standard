# Standard repositories  for Internet2 specific components
 
unique template features/perfsonar-ps/repository/config;
 
include { 'quattor/functions/repository' };

# Ordered list of repository to load
variable PERFSONAR_REPOSITORY_LIST = list('sl5_internet2',
                                     );

'/software/repositories' = add_repositories(PERFSONAR_REPOSITORY_LIST);
