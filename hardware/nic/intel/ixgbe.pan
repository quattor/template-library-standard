######################################################
#
# template hardware/nic/ixgbe;
#
# RESPONSIBLE: Victor Mendoza <mendoza@lpnhe.in2p3.fr>
#
######################################################

structure template hardware/nic/intel/ixgbe;

"driver" = "ixgbe";
"pxe"    = false;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Intel 10 GbE PCIe";
