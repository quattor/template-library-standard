# Default template to use for xrootd config file.
# Can be replaced by a site specific template if needed.
# Role defined here is the default role. Appropriate lines will be added
# based on actual configuration to define the master and the list of workers.


structure template features/proof/xrootd-config-default;

'contents' ?= <<EOF;
### Load the XrdProofdProtocol to serve PROOF sessions
if exec xrootd
xrd.protocol xproofd:1093 libXrdProofd.so
fi
xpd.workdir PROOF_SANDBOX_AREA

xpd.role worker

EOF

