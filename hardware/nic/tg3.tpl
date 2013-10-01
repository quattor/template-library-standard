######################################################
#
# template pro_hardware_card_nic_tg3;
#
# RESPONSIBLE: Charles Loomis <charles.loomis@cern.ch>
#
######################################################

structure template hardware/nic/tg3;

"driver" = "tg3";
"pxe"    = true;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Broadcom Gigabit chip set";
"maxspeed" = 1000;