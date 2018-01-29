structure template hardware/card/gpu/nvidia/tesla_m60;

'manufacturer' = 'nvidia';
'name' = 'tesla_m60';
'model' = 'GM204';
'power' = 300; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 8192; # MB
'ram/bus' = '256-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x13f2;
