structure template hardware/card/gpu/nvidia/quadro_m3000_se;

'manufacturer' = 'nvidia';
'name' = 'quadro_m3000_se';
'model' = 'GM204';
'power' = 75; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 4096; # MB
'ram/bus' = '256-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x13fa;
