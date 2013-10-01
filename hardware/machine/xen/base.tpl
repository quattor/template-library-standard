############################################################
#
# structure template hardware/machine/xen/base
#
# RESPONSIBLE: Stephen Childs <childss@cs.tcd.ie>
#
############################################################

structure template hardware/machine/xen/base;

"location" = "";
"serialnumber" = "";

"cpu" = list(create("hardware/cpu/xen_vcpu"));

"harddisks" = nlist("xvda", create("hardware/harddisk/scsi","capacity", undef));

"ram" = list(create("hardware/ram/generic", "size", undef));

"cards/nic" = nlist("eth0",create("hardware/nic/xen_vif"));

"cards/nic/eth0/hwaddr"              = undef;

"cards/nic/eth0/boot" = true;

