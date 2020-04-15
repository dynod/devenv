# Definitions for development environment settings

DEVENV := .devenv

# Project specific defs
ifdef PROJECT_ROOT

# Common devenv folder
PROJECT_DEVENV_SETTINGS := $(PROJECT_ROOT)/$(DEVENV)

# Source folder
SRC_FOLDER ?= $(PROJECT_ROOT)/src

# Output folder
OUTPUT_ROOT ?= $(PROJECT_ROOT)/out

endif # PROJECT_ROOT
