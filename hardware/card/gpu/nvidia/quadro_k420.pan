structure template hardware/card/gpu/nvidia/quadro_k420;

'manufacturer' = 'nvidia';
'name' = 'quadro_k420';
'model' = 'GK107';
'power' = 41; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 1024; # MB
'ram/bus' = '128-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x0ff3;
