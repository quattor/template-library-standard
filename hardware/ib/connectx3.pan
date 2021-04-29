structure template hardware/ib/connectx3;

"driver" = "mlx4";
"pxe"    = false;
"boot"   = false;
"media"  = "Infiniband";
"name"   = "Mellanox ConnectX-3 VPI IB HCA";
"pci"    = dict(
    "vendor", 0x15b3,
    "device", 0x1003,
    "class", 0x0280,
);

