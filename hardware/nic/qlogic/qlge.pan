######################################################
#
# template hardware/nic/qlge;
#
# RESPONSIBLE: Victor Mendoza <mendoza@lpnhe.in2p3.fr>
#
######################################################

structure template hardware/nic/qlogic/qlge;

"driver" = "qlge";
"pxe"    = true;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Qlogic 10Gb CNA";
