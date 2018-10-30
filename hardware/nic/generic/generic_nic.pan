# This template allows to configure a NIC that has no associated
# static configuration, letting the kernel decide what has to be done.
# It is mainly intended for virtual machines.

structure template hardware/nic/generic/generic_nic;


"pxe"    = true;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Generic Network Interface";
