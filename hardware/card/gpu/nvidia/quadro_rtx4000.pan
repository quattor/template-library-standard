structure template hardware/card/gpu/nvidia/quadro_rtx4000;

'manufacturer' = 'nvidia';
'name' = 'quadro_rtx4000';
'model' = 'TU104';
'power' = 160; # TDP in watts
'bus' = 'PCIe';

'ram/size' = 8192; # MB
'ram/bus' = '4096-bit';

'pci/class' = 0x030000; # Display controller, VGA compatible.
'pci/vendor' = 0x10de; # nVidia Corporation
'pci/device' = 0x1ed3;
