# Shared definitions for Python

# Python settings files
PYTHON_SETTINGS := $(DEVENV)/python

# All Python shared settings folders
ALL_PYTHON_SHARED_SETTINGS := $(foreach P,$(PROJECTS),$(P)/$(PYTHON_SETTINGS)/shared)

# Project specific defs
ifdef PROJECT_ROOT

# Python project settings files
PYTHON_PROJECT_SETTINGS := $(PROJECT_ROOT)/$(PYTHON_SETTINGS)

# Python source files
PYTHON_SRC_FILES := $(shell find $(SRC_FOLDER) -name *.py 2>/dev/null)

# Is Python project?
ifneq ($(PYTHON_SRC_FILES),)
IS_PYTHON_PROJECT := 1

# All Python source files
SRC_FILES := $(PYTHON_SRC_FILES)

# Setup file
PYTHON_SETUP := $(PROJECT_ROOT)/setup.cfg

endif # IS_PYTHON_PROJECT

endif # PROJECT_ROOT
