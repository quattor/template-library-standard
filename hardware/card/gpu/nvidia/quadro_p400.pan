structure template hardware/card/gpu/nvidia/quadro_p400;

'manufacturer' = 'nvidia';
'name' = 'quadro_p400';
'model' = 'GP107';
'power' = 30; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 2048; # MB
'ram/bus' = '64-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1cb3;
