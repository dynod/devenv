# Some definitions for Python virtual environment setup

# Virtual env path
PYTHON_VENV := venv

# Only if current project is a Python one
ifdef IS_PYTHON_PROJECT

# Python binary that will be used to setup the virtual environment
PYTHON_FOR_VENV ?= python3.6

# List project requirements files + shared ones
PYTHON_VENV_REQUIREMENTS := $(shell find $(ALL_PYTHON_SHARED_SETTINGS) $(PYTHON_PROJECT_SETTINGS) -maxdepth 1 -name '*.txt' 2> /dev/null)

# Run command in venv
IN_PYTHON_VENV := source $(PYTHON_VENV)/bin/activate && 

# Python distribution?
ifdef PYTHON_DISTRIBUTION
# Local venv install
PYTHON_DISTRIBUTION_INSTALL := $(PYTHON_VENV)/lib/$(PYTHON_FOR_VENV)/site-packages/$(shell echo $(PYTHON_PACKAGE) | sed -e 's/-/_/g')-$(VERSION).egg-info
endif

ifdef SUB_MAKE
# Triggered at workspace level, don't check system dependencies (already done)
PYTHON_VENV_DEPS := $(PYTHON_VENV_REQUIREMENTS)
else
# Triggered at project level, check system dependencies
PYTHON_VENV_DEPS := $(PYTHON_VENV_REQUIREMENTS) $(SYSDEPS_TIME)
endif

ifdef WORKSPACE_DEPS_MAP
ifndef SUB_MAKE

# Add project dependencies distributions to venv dependencies
PYTHON_VENV_WORKSPACE_REQUIREMENTS := $(shell $(HELPERS_ROOT)/list-deps-dists.sh $(foreach P,$(PROJECT_DEPS_PATHS),$(WORKSPACE_ROOT)/$(P)))
PYTHON_VENV_DEPS += $(PYTHON_VENV_WORKSPACE_REQUIREMENTS)

endif # !SUB_MAKE
endif # WORKSPACE_DEPS_MAP

endif # IS_PYTHON_PROJECT
