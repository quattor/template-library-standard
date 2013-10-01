# This template allows to configure a list of users on a machine based
# on an external list providing a per-machine list of users
#
# This template may be included several times with different input
# parameters.

template users/config;

variable USER_CONFIG_SITE ?= undef;

include { 'components/accounts/config' };
include { 'components/useraccess/config' };

variable USER_PWD_DEF = '*NoLogin*';    # Default is to use ssh keys
variable USER_LIST_SSHKEY_URL_PREFIX ?= undef;
variable USERACCESS_CONFIG_SERIAL ?= '1970-01-01 00:00';

# Load site list of users/groups to create.
include { USER_CONFIG_SITE };

# Shell to use for created accounts if none specified explicitly
variable USER_SHELL_DEF ?= '/bin/bash';

# USER_LIST contains a list of userid and their account parameters.
# Account parameters is a nlist where valid entries are ncm-accounts
# properties for users. Ensure a shell is defined.

variable USER_LIST ?= nlist(
#    'userex', nlist('uid',711,
#                    'groups',list('groupex'),
#                   ),
);
variable USER_LIST = {
  foreach (user;params;SELF) {
    if ( !exists(params['shell']) ) {
      SELF[user]['shell'] = USER_SHELL_DEF;
    };
  };
  SELF;
};

# Nlist with one entry per user a public key must be added to.
# Value of each entry can be a string or a list of string.
# The string must be a valid URL for the user's public key.
variable USER_SSH_KEYS ?= nlist(
#    'userex', USER_LIST_SSHKEY_URL_PREFIX+'userex.pub',
);

# Nlist of group to create. Value is a nlist where entries must be a
# valid property for ncm-accounts groups.
variable GROUP_LIST ?= nlist(
#    'groupex', nlist('gid',800),
);

# Per-machine list of group to create.
# Key is a machine name, value is a list of group names.
# An acccount is created for all group members.
variable DB_MACHINE_GROUPS ?= nlist(
# Following entry will create group groupex on mynode.example.com and an
# account for every groupex member (userex).
#    'mynode.example.com', list('groupex'),
);

# Per-machine list of group to create.
# Key is a machine name, value is a list of group names.
# No additional account will be created for these groups.
variable DB_MACHINE_GROUPS_ONLY ?= nlist(
);

# Per-machine list of users to create.
# Key is a machine name, value is a list of userids.
variable DB_MACHINE_USERS ?= nlist(
);

# Per-machine list of group memberships
# Key is a machine name, value is a nlist with a username as key and a list of groups as value.
# variable DB_MACHINE_USERS_GROUPS = nlist(
#   'mynode.example.com', nlist('userex',list('groupex1','groupex2')),
# );
variable DB_MACHINE_USERS_GROUPS ?= nlist(
);


# Nlist defining entries to apply to a group of machine selected by a regexp.
# Key is the regexp, value is a nlist which must contain a key 'entries' that will
# be used the key to access DB_MACHINE_USERS and DB_MACHINE_GROUPS. 'entries'
# can be a string or list of string. In addition to 'entries', 'alwaysAdd' property may
# be specified (boolean) if the entries defined here must be added even if there is
# an explicit entry for the machine (default is false).
variable DB_MACHINE_DEFAULT_ENTRIES ?= nlist(
);

# Build list of group/user entries applyable to the current machine.
# The list not necessarily the same when 'alwaysAdd' is false.
# Add in the list only existing entries.
variable NODE_USER_GROUP_ENTRIES = {
  group_entries = nlist(FULL_HOSTNAME,'');
  user_entries = nlist(FULL_HOSTNAME,'');
  matched_entries = list();
  foreach (e_regexp;params;DB_MACHINE_DEFAULT_ENTRIES) {
    regexp = unescape(e_regexp);
    if ( exists(params['entries']) ) {
      if ( is_list(params['entries']) ) {
        entries = params['entries'];
      } else if ( is_string(params['entries']) ) {
        entries = list(params['entries']);
      } else {
        error("Invalid value for DB_MACHINE_DEFAULT_ENTRIES entry "+regexp+": 'entries' must be a string or list of string");
      };
      if ( match(FULL_HOSTNAME,regexp) ) {
        always_add = exists(params['alwaysAdd']) && is_defined(params['alwaysAdd']) && params['alwaysAdd'];
        # Insert into nlist first to eliminate duplicates.
        # Ignore entries if an explicit entry for the machine exists and
        # alwaysAdd flag is not true.
        foreach (i;entry;entries) {
          matched_entries[length(matched_entries)] = entry;
          if ( !exists(DB_MACHINE_USERS[entry]) && !exists(DB_MACHINE_GROUPS[entry]) ) {
            error('Entry '+entry+' referenced by DB_MACHINE_DEFAULT_ENTRIES['+regexp+'] does not exist neither in DB_MACHINE_GROUPS nor in DB_MACHINE_USERS');
          };
          if ( exists(DB_MACHINE_USERS[entry]) &&
               (!exists(DB_MACHINE_USERS[FULL_HOSTNAME]) || always_add) ) {
            user_entries[entry] = '';
          };
          if ( exists(DB_MACHINE_GROUPS[entry]) &&
               (!exists(DB_MACHINE_GROUPS[FULL_HOSTNAME]) || always_add) ) {
            group_entries[entry] = '';
          };
        };
      };
    } else {
      error("DB_MACHINE_DEFAULT_ENTRIES entry "+regexp+" has no 'entries' property");
    };
  };
  SELF['matched_entries'] = matched_entries;
  SELF['groups'] = list();
  SELF['users'] = list();
  foreach (entry;v;group_entries) {
    SELF['groups'][length(SELF['groups'])] = entry;
  };
  foreach (entry;v;user_entries) {
    SELF['users'][length(SELF['users'])] = entry;
  };
  
  SELF;
};


# Build list of user and group to define on the machine.
# Remove duplicates, if any.
variable NODE_USER_GROUP_LIST = {
  node_users = nlist();
  node_groups = nlist();

  # Construct a list of groups without duplicates (nlist)
  foreach (i;entry;NODE_USER_GROUP_ENTRIES['groups']) {
    if ( exists(DB_MACHINE_GROUPS[entry]) ) {
      foreach (i;group;DB_MACHINE_GROUPS[entry]) {
        if ( exists(GROUP_LIST[group]) ) {
          node_groups[group] = true;
        } else {
          error('Group '+group+' referenced by DB_MACHINE_GROUPS entry '+entry+' but not defined in GROUP_LIST');
        };
      };
    };
  };

  # If a user is member of a group configured on the machine, add his account
  foreach (user;params;USER_LIST) {
    if ( exists(params['groups']) ) {
      foreach (i;group;params['groups']) {
        if ( exists(node_groups[group]) ) {
          node_users[user] = true;       # Value has no meaning
        };
      };
    };
  };

  # Add groups without their members
  if ( exists(DB_MACHINE_GROUPS_ONLY[entry]) ) {
    foreach (i;group;DB_MACHINE_GROUPS_ONLY[entry]) {
      if ( exists(GROUP_LIST[group]) ) {
        node_groups[group] = true;
      } else {
        error('Group '+group+' referenced by DB_MACHINE_GROUPS entry '+entry+' but not defined in GROUP_LIST');
      };
    };
  };

  # Add to the list of users, all users explicitly configured on this machine without duplicates (nlist)
  foreach (i;entry;NODE_USER_GROUP_ENTRIES['users']) {
    if ( exists(DB_MACHINE_USERS[entry]) ) {
      foreach (i;user;DB_MACHINE_USERS[entry]) {
        if ( exists(USER_LIST[user]) ) {
          node_users[user] = true;
        } else {
          error('User '+user+' referenced by DB_MACHINE_USERS entry '+entry+' but not defined in USER_LIST');
        };
      };
    };
  };

  SELF['missing_users_groups'] = nlist();
  foreach (k;matched_entry;NODE_USER_GROUP_ENTRIES['matched_entries']) {
    if ( is_defined(DB_MACHINE_USERS_GROUPS[matched_entry]) ) {
      foreach (user;group_list;DB_MACHINE_USERS_GROUPS[matched_entry]) {
        if (exists(node_users[user])) {
          tmp_groups=nlist();
          foreach (j;group;USER_LIST[user]['groups']) {
            tmp_groups[group]=true;
          };
          if (!exists(SELF['missing_users_groups'][user])) {
            SELF['missing_users_groups'][user]=list();
          };
          foreach (j;group;group_list) {
            if (!is_defined(tmp_groups[group])) {
              SELF['missing_users_groups'][user][length(SELF['missing_users_groups'][user])] = group;
            };
          };
        };
      };
    };
  };
  
  if ( exists(DB_MACHINE_USERS_GROUPS[FULL_HOSTNAME]) ) {
    
    foreach (user;group_list;DB_MACHINE_USERS_GROUPS[FULL_HOSTNAME]) {
      if (exists(node_users[user])) {
        tmp_groups=nlist();
        foreach (j;group;USER_LIST[user]['groups']) {
          tmp_groups[group]=true;
        };
        if (!exists(SELF['missing_users_groups'][user])) {
          SELF['missing_users_groups'][user]=list();
        };
        foreach (j;group;group_list) {
          if (!is_defined(tmp_groups[group])) {
            SELF['missing_users_groups'][user][length(SELF['missing_users_groups'][user])] = group;
          };
        };
      };
    };    
  };

  SELF['users'] = list();
  SELF['groups'] = list();
  if ( length(node_users) > 0 ) {
    foreach (user;v;node_users) {
      SELF['users'][length(SELF['users'])] = user;
    };
  };
  if ( length(node_groups) > 0 ) {
    foreach (group;v;node_groups) {
      SELF['groups'][length(SELF['groups'])] = group;
    };
  };
  
  SELF;
};

variable USER_LIST = {
  user_list = SELF;
  if (is_defined(NODE_USER_GROUP_LIST['missing_users_groups'])) {
    foreach(user;groups;NODE_USER_GROUP_LIST['missing_users_groups']) {
      user_list[user]['groups'] = merge(user_list[user]['groups'],groups);
    };
  };
  foreach (e_regexp;params;DB_MACHINE_DEFAULT_ENTRIES) {
    regexp = unescape(e_regexp);
    if ( exists(params['entries']) ) {
      if ( is_list(params['entries']) ) {
        entries = params['entries'];
      } else if ( is_string(params['entries']) ) {
        entries = list(params['entries']);
      } else {
        error("Invalid value for DB_MACHINE_DEFAULT_ENTRIES entry "+regexp+": 'entries' must be a string or list of string");
      };
      if ( match(FULL_HOSTNAME,regexp) ) {
        foreach (i;entry;entries) {
          if ( is_defined(USER_LIST_OVERRIDES[entry]) ) {
            foreach (j;user;USER_LIST_OVERRIDES[entry]) {
              foreach (k;attribute;user) {
                user_list[j][k]=attribute;
              }
            };
          };
        };
      };
    } else {
      error("DB_MACHINE_DEFAULT_ENTRIES entry "+regexp+" has no 'entries' property");
    };
  };
  if ( exists(USER_LIST_OVERRIDES[FULL_HOSTNAME]) ) {
    foreach (j;user;USER_LIST_OVERRIDES[FULL_HOSTNAME]) {
      foreach (k;attribute;user) {
        user_list[j][k]=attribute;
      }
    };
  };
  user_list;
};

'/software/components/accounts' = {
  account_config = SELF;
  
  if ( length(NODE_USER_GROUP_LIST['groups']) > 0 ) {
    account_config = create_accounts_from_db(GROUP_LIST,
                                             NODE_USER_GROUP_LIST['groups'],
                                             1);
  };

  if ( length(NODE_USER_GROUP_LIST['users']) > 0 ) {
    user_config = create_accounts_from_db(USER_LIST,
                                          NODE_USER_GROUP_LIST['users']);
  };
  
  account_config;
};

'/software/components/useraccess' = {
  # Add root to the list of users considered for SHH key configuration
  user_list = NODE_USER_GROUP_LIST['users'];
  user_list[length(user_list)] = 'root';
  foreach (i;user;user_list) {
    key_list = undef;
    if ( exists(USER_SSH_KEYS[user]) ) {
      if ( is_list(USER_SSH_KEYS[user]) ) {
        key_list = USER_SSH_KEYS[user];
      } else if ( is_string(USER_SSH_KEYS[user]) ) {
        key_list = list(USER_SSH_KEYS[user]);
      } else {
        error('SSH key list must a be a string or a list of string');
      };
      SELF['users'][user]['ssh_keys_urls'] = key_list;
    };
  };
  
  if ( exists(SELF['users']) && is_defined(SELF['users']) ) {
    SELF['configSerial'] = USERACCESS_CONFIG_SERIAL;
    SELF['dependencies']['pre'] = list('accounts');
  } else {
    SELF['users'] = nlist();
  };
  return(SELF);
};
