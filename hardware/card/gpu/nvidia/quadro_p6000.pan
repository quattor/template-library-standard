structure template hardware/card/gpu/nvidia/quadro_p6000;

'manufacturer' = 'nvidia';
'name' = 'quadro_p6000';
'model' = 'GP102';
'power' = 250; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 24576; # MB
'ram/bus' = '384-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1b30;
