######################################################
#
# template pro_hardware_card_nic_pcnet32;
#
# RESPONSIBLE: Charles Loomis <charles.loomis@cern.ch>
#
######################################################

structure template hardware/nic/amd/pcnet32;

"driver" = "pcnet32";
"pxe"    = true;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "AMD PCNet 32";
