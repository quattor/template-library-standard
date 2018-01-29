structure template hardware/card/gpu/nvidia/quadro_k4200;

'manufacturer' = 'nvidia';
'name' = 'quadro_k4200';
'model' = 'GK104';
'power' = 108; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 4096; # MB
'ram/bus' = '256-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x11b4;
