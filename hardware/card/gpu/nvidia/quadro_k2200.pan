structure template hardware/card/gpu/nvidia/quadro_k2200;

'manufacturer' = 'nvidia';
'name' = 'quadro_k2200';
'model' = 'GM107';
'power' = 68; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 4096; # MB
'ram/bus' = '128-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x13ba;
