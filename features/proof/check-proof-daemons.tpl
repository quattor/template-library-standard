
unique template features/proof/check-proof-daemons;

include { 'components/filecopy/config' };

variable PROOF_CHECKDAEMONS_SCRIPT = 'check-proof-daemons';
variable PROOF_CHECKDAEMONS_FILE = '/root/scripts/'+PROOF_CHECKDAEMONS_SCRIPT;
# Check interval in minutes. Default: 5 mn.
# Define to null or 0 to suppress the periodic check.
variable PROOF_CHECKDAEMONS_INTERVAL = {
  if ( is_defined(SELF) || is_null(SELF) ) {
    SELF;
  } else {
    5;
  };
};

variable PROOF_CHECKDAEMONS_TEMPLATE = <<EOF;
#!/bin/bash

service=/sbin/service

for daemon in PROOF_SERVICE
do
  #echo Checking $daemon status...
  ${service} $daemon status > /dev/null
  if [ $? -eq 2 ]         # Daemon is dead
  then
    echo "Restarting $daemon..."
    ${service} $daemon start
  fi
done

EOF


# Create script with appropriate daemon list to check

'/software/components/filecopy/services' = {
  if ( length(PROOF_SERVICE) > 0 ) {
    contents = replace('PROOF_SERVICE',PROOF_SERVICE,PROOF_CHECKDAEMONS_TEMPLATE);
    SELF[escape(PROOF_CHECKDAEMONS_FILE)] =  nlist('config', contents,
                                                 'owner', 'root:root',
                                                 'perms', '0755'
                                                );
  };
  SELF;
};


# Add the script as a cron job if interval is greater than 0

"/software/components/cron/entries" = {
  if ( is_defined(PROOF_CHECKDAEMONS_INTERVAL) && (PROOF_CHECKDAEMONS_INTERVAL > 0) ) {
    SELF[length(SELF)] = nlist("name",PROOF_CHECKDAEMONS_SCRIPT,
                               "user","root",
                               "frequency", '*/'+to_string(PROOF_CHECKDAEMONS_INTERVAL)+" * * * *",
                               "command", "PATH=/sbin:/bin:/usr/sbin:/usr/bin; " + PROOF_CHECKDAEMONS_FILE,
                              );
  };
  SELF;
};

"/software/components/altlogrotate/entries" = {
  if ( is_defined(PROOF_CHECKDAEMONS_INTERVAL) && (PROOF_CHECKDAEMONS_INTERVAL > 0) ) {
    SELF[PROOF_CHECKDAEMONS_SCRIPT] = nlist("pattern", "/var/log/"+PROOF_CHECKDAEMONS_SCRIPT+".ncm-cron.log",
                                          "compress", true,
                                          "missingok", true,
                                          "frequency", "weekly",
                                          "create", true,
                                          "ifempty", true,
                                         );
  };
  SELF;
};

