# Shared definitions for Python

# Python settings files
PYTHON_SETTINGS := $(DEVENV)/python

# All Python shared settings folders
ALL_PYTHON_SHARED_SETTINGS := $(foreach P,$(PROJECTS),$(P)/$(PYTHON_SETTINGS)/shared)

# Project specific defs
ifdef PROJECT_ROOT

# Python project settings files
PYTHON_PROJECT_SETTINGS := $(PROJECT_ROOT)/$(PYTHON_SETTINGS)

# Is Python project?
ifneq ("$(wildcard $(PYTHON_PROJECT_SETTINGS))","")
IS_PYTHON_PROJECT := 1
endif

endif # PROJECT_ROOT
