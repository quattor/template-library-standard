structure template hardware/card/raid/dell/perc_h755;

'bbu' = true;
'bus' = 'PCI-E';
'cache' = 8192 * MB;
'manufacturer' = 'lsi';
'model' = 'PERC H755';
'numberports' = 16;
'ports' = dict();
'vendor' = 'dell';

'pci/vendor' = 0x1000; # Broadcom / LSI
'pci/device' = 0x10e2; # MegaRAID 12GSAS/PCIe Secure SAS39xx
'pci/class' = 0x0104; # RAID bus controller
