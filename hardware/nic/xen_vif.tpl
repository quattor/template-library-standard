######################################################
#
# template hardware/nic/xen_vif
#
# RESPONSIBLE: Stephen Childs <childss@cs.tcd.ie>
#
######################################################

structure template hardware/nic/xen_vif;

"driver" = "xen";
"pxe"    = true;
"boot"   = true;
"media"  = "Ethernet";
"name"   = "Xen Virtual NIC";
