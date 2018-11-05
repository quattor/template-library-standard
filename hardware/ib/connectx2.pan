structure template hardware/ib/connectx2;

"driver" = "mlx4";
"pxe"    = false;
"boot"   = false;
"media"  = "Infiniband";
"name"   = "Mellanox ConnectX-2 VPI IB HCA";
"pci"    = dict(
    "vendor", 0x15b3,
    "device", 0x1002,
    "class", 0x0c06,
);
