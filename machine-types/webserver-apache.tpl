############################################################
#
# template machine-types/webserver-apache
#
# Defines configuration of an apache webserver.
#
# RESPONSIBLE: Christos Triantafyllidis <ctria@grid.auth.gr>
#
############################################################

template machine-types/webserver-apache;

#
# Include base configuration of a node
#
include { 'machine-types/core' };

# Add Web server feature (apache)
#
include { 'features/webserver-apache/service' };
