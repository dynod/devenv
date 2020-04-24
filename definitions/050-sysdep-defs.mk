# System dependencies

# System settings files
SYSTEM_SETTINGS := $(DEVENV)/system

# All system settings
ALL_SYSTEM_SETTINGS := $(foreach P,$(PROJECTS),$(P)/$(SYSTEM_SETTINGS))

# Databases listing "how to install" missing packages
SYSDEP_DATABASE := $(shell find $(ALL_SYSTEM_SETTINGS) -name sysdeps.json 2> /dev/null)

# All system requirements
SYSDEP_REQUIREMENTS := $(shell find $(ALL_SYSTEM_SETTINGS) -name '*.txt' 2> /dev/null)

# System install log
SYS_INSTALL_LOG := /var/log/dpkg.log

# User install stamp (to keep timestamp of last system deps verification)
SYSDEPS_TIME := $(CACHE_SHARED_DIR)/sysdeps.time

# Reinstall?
ifdef SYSDEPS_REINSTALL
SYSDEPS_CLEAN_CACHE := $(shell rm -f $(SYSDEPS_TIME))
endif
