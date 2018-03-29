structure template hardware/card/gpu/nvidia/quadro_m6000;

'manufacturer' = 'nvidia';
'name' = 'quadro_m6000';
'model' = 'GM200';
'power' = 250; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 12288; # MB
'ram/bus' = '384-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x17f0;
