structure template hardware/card/gpu/nvidia/quadro_gp100;

'manufacturer' = 'nvidia';
'name' = 'quadro_gp100';
'model' = 'GP100';
'power' = 235; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 16384; # MB
'ram/bus' = '4096-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x15f0;
