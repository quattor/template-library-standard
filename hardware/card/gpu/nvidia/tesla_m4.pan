structure template hardware/card/gpu/nvidia/tesla_m4;

'manufacturer' = 'nvidia';
'name' = 'tesla_m4';
'model' = 'GM206';
'power' = 50; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 4096; # MB
'ram/bus' = '128-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1431;
