structure template hardware/card/gpu/nvidia/quadro_p5000;

'manufacturer' = 'nvidia';
'name' = 'quadro_p5000';
'model' = 'GP104';
'power' = 180; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 16384; # MB
'ram/bus' = '256-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1bb0;
