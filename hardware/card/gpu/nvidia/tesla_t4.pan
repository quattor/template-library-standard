structure template hardware/card/gpu/nvidia/tesla_t4;

'manufacturer' = 'nvidia';
'name' = 'tesla_t4';
'model' = 'TU104GL';
'power' = 70; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 16384; # MB
'ram/bus' = '256-bit';

'pci/class' = 0x0302; # 3D Controller
'pci/vendor' = 0x10de; # NVIDIA Corporation
'pci/device' = 0x1eb8; # TU104GL [Tesla T4]
