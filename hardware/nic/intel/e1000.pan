######################################################
#
# from template pro_hardware_card_nic_e1000;
#
# RESPONSIBLE: Charles Loomis <charles.loomis@cern.ch>
#
######################################################

structure template hardware/nic/intel/e1000;

"driver" = "e1000";
"pxe"    = false;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Intel e1000 Gigabit card";
"maxspeed" = 1000;
