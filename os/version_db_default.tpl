# This template provides configuration hacks defaults for each
# supported OS version.
# Can be overridden in site database

unique template os/version_db_default;

# Deprecated starting with gLite 3.1

variable GLITE_CONFIG_HACKS_DB ?= nlist(
  escape("sl308-i386"),      "os/pro_os_glite_postconfig",
  escape("sl430-i386"),      "os/pro_os_glite_postconfig",
  escape("sl430-x86_64"),	   "os/pro_os_glite_postconfig",
  escape("sl440-i386"),      "config/glite/3.0/postconfig",
  escape("sl440-x86_64"),	   "config/glite/3.0/postconfig",
  escape("sl450-x86_64"),	   "config/glite/3.0/postconfig",
);
