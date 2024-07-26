structure template hardware/card/gpu/nvidia/a4000;

'manufacturer' = 'nvidia';
'name' = 'a4000';
'model' = 'GA104GL';
'power' = 140; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 16384; # MB
'ram/bus' = '256-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # NVIDIA Corporation
'pci/device' = 0x24b0; # GA104GL [RTX A4000]
