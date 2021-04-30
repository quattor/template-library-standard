structure template hardware/card/gpu/nvidia/tesla_v100-pcie-32gb;

'manufacturer' = 'nvidia';
'name' = 'tesla_v100-pcie-32gb';
'model' = 'GV100';
'power' = 250; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 32768; # MB
'ram/bus' = '4096-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1db6;
