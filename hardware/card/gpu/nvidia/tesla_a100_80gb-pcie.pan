structure template hardware/card/gpu/nvidia/tesla_a100_80gb-pcie;

'manufacturer' = 'nvidia';
'name' = 'tesla_a100_80gb-pcie';
'model' = 'GA100';
'power' = 300; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 81920; # MB
'ram/bus' = '5120-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # NVIDIA Corporation
'pci/device' = 0x20b5; # GA100 [A100 PCIe 80GB]
