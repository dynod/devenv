# Helpers location
HELPERS_ROOT := $(DEVENV_ROOT)/helpers

# Helper for status display
STATUS_HELPER := $(HELPERS_ROOT)/status.py

# Status macros
ifdef PROJECT_ROOT
HELPER_OPTS = -w $(WORKSPACE_ROOT) -p $(PROJECT_ROOT) -t $@
else # !PROJECT_ROOT
HELPER_OPTS = -w $(WORKSPACE_ROOT) -p $(WORKSPACE_ROOT) -t $@
endif

# If make sub-process, don't clean logs
ifdef SUB_MAKE
STATUS_NO_CLEAN := 1
endif

# Build logs (clean on each make call)
BUILD_LOGS ?= /tmp/build-logs
ifdef STATUS_NO_CLEAN
BUILD_LOGS_RESOLVED := $(BUILD_LOGS)
else
BUILD_LOGS_RESOLVED := $(shell rm -Rf $(BUILD_LOGS) && echo $(BUILD_LOGS))
endif
HELPER_OPTS += -o $(BUILD_LOGS_RESOLVED)

# Verbose commands
ifdef STATUS_VERBOSE
HELPER_OPTS += --verbose
endif

# Status helper
STATUS = $(STATUS_HELPER) $(HELPER_OPTS)

# Status shortcuts
BUILD_STATUS = $(STATUS) -i build
CLEAN_STATUS = $(STATUS) -i clean
SETUP_STATUS = $(STATUS) -i setup
GIFT_STATUS = $(STATUS) -i gift
SLEEP_STATUS = $(STATUS) -i sleep
STUB_STATUS = $(SLEEP_STATUS) -s "Nothing to do"
MULTI_STATUS = $(STATUS) -i multi
SYNC_STATUS = $(STATUS) -i sync
BRANCH_STATUS = $(STATUS) -i branch
FLOPPY_STATUS = $(STATUS) -i floppy
CROSS_FINGER_STATUS = $(STATUS) -i cross_finger
EYE_STATUS = $(STATUS) -i eye
FILE_STATUS = $(STATUS) -i file
LIPSTICK_STATUS = $(STATUS) -i lipstick
INSTALL_STATUS = $(STATUS) -i install
TOOLBOX_STATUS = $(STATUS) -i toolbox
FILEBOX_STATUS = $(STATUS) -i filebox

# Helper for system dependencies
SYSDEPS_HELPER = $(HELPERS_ROOT)/sysdeps.py $(HELPER_OPTS)

# Non interractive install
ifdef SYSDEPS_YES
SYSDEPS_HELPER += --yes
endif

# Forced reinstall
ifdef SYSDEPS_REINSTALL
SYSDEPS_HELPER += --reinstall
endif

# Helper for settings builder
SETTINGS_BUILDER := $(HELPERS_ROOT)/settings_builder.py

# CPU count (for tools unable to detect it)
CPU_COUNT = $(shell grep processor /proc/cpuinfo | wc -l)
