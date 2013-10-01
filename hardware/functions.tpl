# Functions used to build HW description of a machine

unique template hardware/functions;


# Function updating HW description from parameters specified in variable
# MACHINE_PARAMS
# Returns an updated /hardware
function update_hw_params = {
  if ( exists(MACHINE_PARAMS[FULL_HOSTNAME]) && is_nlist(MACHINE_PARAMS[FULL_HOSTNAME]) ) {
    foreach (param;value;MACHINE_PARAMS[FULL_HOSTNAME]) {
      if ( param == 'ram' ) {
        SELF['ram'][0]['size'] = value;
      } else if ( param == 'disk' ) {
        if ( exists(SELF['harddisks']) && is_defined(SELF['harddisks']) ) {
          ok = first(SELF['harddisks'],disk,v);
        } else {
          ok = false;
        };
        if ( ok ) {
          SELF['harddisks'][disk]['capacity'] = value;
        } else {
          error('No hard disk found in HW configuration');
        }; 
      } else if ( param == 'mac' ) {
        SELF['cards']['nic']['eth0']['hwaddr'] = value;
      };
    };
  };

  SELF;
};
