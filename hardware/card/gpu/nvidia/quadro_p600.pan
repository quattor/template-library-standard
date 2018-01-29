structure template hardware/card/gpu/nvidia/quadro_p600;

'manufacturer' = 'nvidia';
'name' = 'quadro_p600';
'model' = 'GP107';
'power' = 40; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 2048; # MB
'ram/bus' = '128-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1cb2;
