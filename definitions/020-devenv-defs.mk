# Definitions for development environment settings

DEVENV := .devenv

# Project specific defs
ifdef PROJECT_ROOT

# Common devenv folder
PROJECT_DEVENV_SETTINGS := $(PROJECT_ROOT)/$(DEVENV)

# Output folder
OUTPUT_ROOT ?= $(PROJECT_ROOT)/out

endif # PROJECT_ROOT
