structure template hardware/nic/by_driver/e1000e;

# This driver supports all Intel PCI-Express Gigabit Network Interfaces
# Except those that are 82575, 82576 and 82580-based (which use the igb driver)

"driver" = "e1000e";
"pxe"    = false;
"boot"   = false;
"media"  = "Ethernet";
"name"   = "Intel(R) PRO/1000 Network Driver (PCIe)";
"maxspeed" = 1000;
"manufacturer" = "intel";
