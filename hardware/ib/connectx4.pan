structure template hardware/ib/connectx4;

"driver" = "mlx5";
"pxe"    = false;
"boot"   = false;
"media"  = "Infiniband";
"name"   = "Mellanox Technologies MT27700 Family [ConnectX-4]";
"pci"    = dict(
    "vendor", 0x15b3,
    "device", 0x1013,
    "class", 0x0207,
);
