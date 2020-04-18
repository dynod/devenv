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

# Artifacts folder
ARTIFACTS_ROOT ?= $(OUTPUT_ROOT)/artifacts

# Version
VERSION ?= $(shell git describe --tags 2>/dev/null || echo "0.0")

endif # PROJECT_ROOT
