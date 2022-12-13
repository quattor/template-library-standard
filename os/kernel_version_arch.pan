# Template to define kernel version and archicture related variables

unique template os/kernel_version_arch;

variable KERNEL_VERSION_CONFIG ?= null;

variable OS_ERRATA_INIT ?= 'config/os/errata/init';

variable KERNEL_OS_VERSION_PARAMS ?= if ( is_defined(OS_VERSION_PARAMS) ) {
    OS_VERSION_PARAMS;
} else if ( is_defined(OS_VERSION_PARAMS_DEFAULT) ) {
    OS_VERSION_PARAMS_DEFAULT;
} else {
    error('OS_VERSION_PARAMS undefined, unable to configure the kernel');
};

variable DEBUG = debug('KERNEL_OS_VERSION_PARAMS=%s', to_string(KERNEL_OS_VERSION_PARAMS));

# Function to define architecture to use.
# DISTRIB_ARCH is a special value translated to the architecture of the distribution
# used on the current node. This allows to install a 32-bit OS on a 64-bit capable machine.
# Use CPU architecture defined in CPU HW template as a last resort as it prevents running 32-bit
# OS on a 64-bit capable CPU.
function arch_from_cpu = {
    if ( exists("/hardware/cpu/0/vendor") ) {
        vendor = value("/hardware/cpu/0/vendor");
    } else if ( exists("/hardware/cpu/0/manufacturer") ) {
        vendor = value("/hardware/cpu/0/manufacturer");
    };
    if ( !exists(vendor) || !exists(CPU_VENDOR_TO_ARCH[vendor]) ) {
        vendor = 'DEFAULT';
    };
    if ( exists(CPU_VENDOR_TO_ARCH[vendor]) ) {
        arch = CPU_VENDOR_TO_ARCH[vendor];
    } else if ( exists("/hardware/cpu/0/arch") ) {
        arch = value("/hardware/cpu/0/arch");
    } else {
        arch = undef;
    };

    if ( !is_defined(arch) ) {
        error('Unable to guess OS architecture from CPU characteristrics');
    } else if ( arch == 'DISTRIB_ARCH' ) {
        if ( is_defined(KERNEL_OS_VERSION_PARAMS['arch']) ) {
            arch = KERNEL_OS_VERSION_PARAMS['arch'];
            if ( arch == 'i386' ) {
                # If 'athlon' is needed (SL3), must be set explicitly using variable CPU_VENDOR_TO_ARCH
                # in OS specific template config/os/kernel_version_arch.tpl.
                arch = 'i686';
            };
        } else {
            error('Distribution architecture not found, unable to guess OS architecture used');
        };
    };

    if ( exists("/hardware/cpu/0/arch")
            && (value("/hardware/cpu/0/arch") == 'i386')
            && !match(arch, 'i686|athlon') ) {
        error('OS architecture %s unsupported on CPU arch %s', arch, value("/hardware/cpu/0/arch"));
    };

    arch;
};


# Include OS version specific configuration if any.
# May redefined any of the variables define below as they are just default values.
include if_exists('config/os/kernel_version_arch');

# Include specific parameters set by errata (mainly kernel version)
include if_exists(OS_ERRATA_INIT);

# Define default versions for kernel based on OS version (architecture independent).
# They will be merged with site defaults later.
variable OS_KERNEL_VERSION_DEFAULT ?= dict(
);

# Always use largesmp by default. Override in config/os/kernel_version_arch.tpl in
# templates for the OS version if not appropriate.
variable KERNEL_SMP_PARAMS ?= dict(
    'limit', 4096,
    'largesmp', 'largesmp',
    'smp', 'largesmp',
);

variable CPU_VENDOR_TO_ARCH ?= dict(
    "DEFAULT", "DISTRIB_ARCH",
);


# Load OS errata initialization template and site-specific template
# that may redefine some defaults, in particular kernel version to use.
# OS errata may define a new kernel version to use for one (or more) OS
# version through variable (dict) OS_KERNEL_VERSION_ERRATA.

# Include only if it exists. Not supported for old OS templates (before SL 4.4).
include if_exists(OS_ERRATA_INIT);

variable OS_KERNEL_VERSION_DEFAULT = {
    if ( is_defined(OS_KERNEL_VERSION_ERRATA) ) {
        foreach (os; kernel; OS_KERNEL_VERSION_ERRATA) {
            SELF[os] = kernel;
        };
    };
    SELF;
};

include KERNEL_VERSION_CONFIG;

variable OS_KERNEL_VERSION = {
    foreach (os; kernel; OS_KERNEL_VERSION_DEFAULT) {
        if ( !is_defined(SELF[os]) ) {
            SELF[os] = kernel;
        };
    };
    SELF;
};


#
# kernel version related variables
# Define variables :
#     - KERNEL_VERSION_NUM : kernel version number
#     - KERNEL_VARIANT : smp, hugemem...

variable KERNEL_EXPLICITLY_DEFINED = is_defined(KERNEL_VERSION_NUM) || is_defined(KERNEL_VARIANT);

# If KERNEL_VERSION_NUM is not defined (recommended), build it from OS_KERNEL_VERSION entries.
# First a match is attempted on the version+architecture, then on version only.
# If there is no match, don't define the kernel version (probably managed  by YUM)
variable KERNEL_VERSION_NUM ?= {
    if ( is_defined(NODE_OS_VERSION) ) {
        if ( is_defined(OS_KERNEL_VERSION[NODE_OS_VERSION]) ) {
            # Kernel version specific to version+arch
            OS_KERNEL_VERSION[NODE_OS_VERSION];
        } else if ( is_defined(KERNEL_OS_VERSION_PARAMS['version']) &&
                    is_defined(OS_KERNEL_VERSION[KERNEL_OS_VERSION_PARAMS['version']]) ) {
            OS_KERNEL_VERSION[KERNEL_OS_VERSION_PARAMS['version']];
        } else {
            # Variant defined but no version explicitly defined and none found in the default list
            if ( KERNEL_EXPLICITLY_DEFINED ) {
                error(
                    'Kernel variant defined to %s but no default kernel version could be found for OS version %s',
                    KERNEL_VARIANT, NODE_OS_VERSION,
                    );
            } else {
                debug(
                    'No default kernel version defined for OS version/arch %s (version=%s)',
                    NODE_OS_VERSION,
                    to_string(KERNEL_OS_VERSION_PARAMS['version'])
                    );
            };
        };
    } else {
        error('No OS version defined : unable to guess kernel version. Define variable KERNEL_VERSION_NUM.');
    };
};

variable KERNEL_VARIANT ?= undef;

#
# Define variables related to CPU architecture.
# Used to select appropriate version of some packages.
# arch_from_cpu returns a value based on cpu vendor (must be called after HW
# definition). To override this default value, define CPU_ARCH before.
#
variable CPU_ARCH ?= arch_from_cpu();
variable PKG_ARCH_DEFAULT ?= if ( match(CPU_ARCH, 'i686|athlon') ) {
    'i386'
} else {
    CPU_ARCH
};
variable PKG_ARCH_JAVA ?= if ( PKG_ARCH_DEFAULT == 'i386' ) {
    'i586'
} else {
    PKG_ARCH_DEFAULT
};
# Hack to handle hugemem variant on SL3 which exists only as i686
variable PKG_ARCH_KERNEL ?= if ( (CPU_ARCH == 'athlon') && (KERNE_VARIANT == 'hugemem') ) {
    'i686'
} else {
    CPU_ARCH
};
variable PKG_ARCH_GLIBC ?= if ( CPU_ARCH == 'athlon' ) {
    'i686'
} else {
    CPU_ARCH
};
variable PKG_ARCH_OPENSSL ?= PKG_ARCH_GLIBC;
variable PKG_ARCH_KERNEL_MODULE_OPENAFS ?= PKG_ARCH_KERNEL;
# Deprecated. For SL 3.05 templates compatibility
variable PKG_ARCH_KERNEL_SMP ?= PKG_ARCH_KERNEL;

variable CPU_ARCH_64BIT ?= if ( CPU_ARCH == 'x86_64' ) {
    true
} else {
    false
};


# Define kernel version.
# KERNEL_VERSION cannot be overriden directly to avoid inconsistencies with
# other kernel related variables.

variable KERNEL_VERSION = {
    debug('KERNEL_EXPLICITLY_DEFINED=%s', to_string(KERNEL_EXPLICITLY_DEFINED));
    debug('KERNEL_OS_VERSION_PARAMS=%s', to_string(KERNEL_OS_VERSION_PARAMS));
    debug('Kernel version=%s, Kernel variant=%s', to_string(KERNEL_VERSION_NUM), to_string(KERNEL_VARIANT));
    if ( KERNEL_EXPLICITLY_DEFINED  || !is_defined(KERNEL_OS_VERSION_PARAMS['flavour']) ) {
        if ( is_defined(KERNEL_VARIANT) ) {
            variant = KERNEL_VARIANT;
        } else {
            variant = '';
        };
        version = KERNEL_VERSION_NUM + variant;
        if ( is_defined(KERNEL_OS_VERSION_PARAMS) &&
            match(KERNEL_OS_VERSION_PARAMS['distribution'], '^sl$') &&
            (KERNEL_OS_VERSION_PARAMS['majorversion'] >= '6') ) {
            version = version + '.' + PKG_ARCH_KERNEL;
        };
        version;
    } else {
        undef
    };
};

# Do not define with sl5.x and sl6.x if default kernel versions are used: let yum do whatever is appropriate.
# As /system/kernel/version cannot be let undef until 14.8, use a magic value not matching any kernel.
# Note: /system/kernel/version used to be defined in machine-types/xxx/base and thus
# this value may be overwritten later in many cases... Change site templates if needed.

include if_exists('quattor/client/version');
'/system/kernel/version' = {
    if ( !KERNEL_EXPLICITLY_DEFINED && is_defined(KERNEL_OS_VERSION_PARAMS['flavour']) ) {
        # Consider that 14.1xx is >= 14.10 as 14.1 never existed
        if ( is_defined(QUATTOR_RELEASE) && ((QUATTOR_RELEASE >= '15') || match(QUATTOR_RELEASE, '^14\.[189]')) ) {
            null;
        } else {
            'YUM-managed';
        };
    } else {
        KERNEL_VERSION;
    };
};

# Lock kernel version if using YUM-based deployment and a version has been explicitly defined
# Variable PKG_LOCK_KERNEL_VERSION can be used to disable kernel version definition
# even though kernel version has been explicitly defined in the configuration.
include 'components/spma/config';
variable PACKAGE_MANAGER ?= if ( exists('/software/components/spma/packager') &&
                                is_defined(value('/software/components/spma/packager')) ) {
    value('/software/components/spma/packager')
} else {
    'spma';
};
variable PKG_LOCK_KERNEL_VERSION ?= if ( PACKAGE_MANAGER == 'yum' ){
    true;
} else {
    false;
};
'/software/packages' = {
    if ( KERNEL_EXPLICITLY_DEFINED && PKG_LOCK_KERNEL_VERSION ) {
        debug('locking kernel version to: %s', KERNEL_VERSION_NUM);
        pkg_repl('kernel*', KERNEL_VERSION_NUM, PKG_ARCH_KERNEL);
    };
    SELF;
};
