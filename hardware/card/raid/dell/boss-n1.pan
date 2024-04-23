structure template hardware/card/raid/dell/boss-n1;

'manufacturer' = 'dell';
'model' = 'BOSS-N1';
'bus' = 'PCI-E';
'bbu' = true;
'numberports' = 2;
'cache' = 0 * MB;
'ports' = dict();

'pci/vendor' = 0x1b4b; # Marvell Technology Group Ltd
'pci/device' = 0x2241; # 88NR2241 Non-Volatile memory controller
'pci/class' = 0x0108; # Non-Volatile memory controller
