######################################################
#
# RESPONSIBLE: Jacquelin Charbonnel <charbonnel@lal.in2p3.fr>
#
######################################################

structure template hardware/nic/broadcom/bcm5700;

"driver" = "bcm5700";
"driverrpms" = list("bcm5700", "bcm5700-smp");
"pxe"    = true;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Broadcom PCI-X 10/100/1000BASE-T Controller";
