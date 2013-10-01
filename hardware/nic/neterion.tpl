######################################################
#
# from template pro_hardware_card_nic_e1000;
#
# RESPONSIBLE: Charles Loomis <charles.loomis@cern.ch>
#
######################################################

structure template hardware/nic/neterion;

"driver" = "s2io";
"pxe"    = false;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Neterion XFrame 10Gb card";
