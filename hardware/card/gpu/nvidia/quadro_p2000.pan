structure template hardware/card/gpu/nvidia/quadro_p2000;

'manufacturer' = 'nvidia';
'name' = 'quadro_p2000';
'model' = 'GP106';
'power' = 75; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 5120; # MB
'ram/bus' = '160-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1c30;
