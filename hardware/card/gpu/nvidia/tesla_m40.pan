structure template hardware/card/gpu/nvidia/tesla_m40;

'manufacturer' = 'nvidia';
'name' = 'tesla_m40';
'model' = 'GM200';
'power' = 250; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 12288; # MB
'ram/bus' = '384-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x17fd;
