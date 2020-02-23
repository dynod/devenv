# Shared definitions for Python

# Python settings files
PYTHON_SETTINGS := $(DEVENV)/python

# Python shared settings files
PYTHON_SHARED_SETTINGS := $(TOOLS_ROOT)/$(PYTHON_SETTINGS)

# Project specific defs
ifdef PROJECT_ROOT

# Python project settings files
PYTHON_PROJECT_SETTINGS := $(PROJECT_ROOT)/$(PYTHON_SETTINGS)

# Is Python project?
ifneq ("$(wildcard $(PYTHON_PROJECT_SETTINGS))","")
IS_PYTHON_PROJECT := 1
endif

endif # PROJECT_ROOT
