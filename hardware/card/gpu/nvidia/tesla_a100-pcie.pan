structure template hardware/card/gpu/nvidia/tesla_a100-pcie;

'manufacturer' = 'nvidia';
'name' = 'tesla_a100-pcie';
'model' = 'GA100';
'power' = 300; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 40960; # MB
'ram/bus' = '4096-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x20f1;
