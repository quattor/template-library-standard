######################################################
#
# template hardware/nic/myri10ge;
#
# RESPONSIBLE: Liliana Martin
######################################################

structure template hardware/nic/myricom/myri10ge;

"driver" = "myri10ge";
"pxe"    = false;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Intel 10 GbE PCIe";
