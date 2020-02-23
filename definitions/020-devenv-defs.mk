# Definitions for development environment settings

DEVENV := .devenv

# Project specific defs
ifdef PROJECT_ROOT

PROJECT_DEVENV_SETTINGS := $(PROJECT_ROOT)/$(DEVENV)

endif # PROJECT_ROOT
