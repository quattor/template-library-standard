structure template hardware/card/gpu/nvidia/quadro_p500;

'manufacturer' = 'nvidia';
'name' = 'quadro_p500';
'model' = 'GP108';
'power' = 30; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 2048; # MB
'ram/bus' = '64-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1d33;
