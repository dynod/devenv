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
VERSION ?= $(shell git describe --tags 2>/dev/null || echo "0.0-`git describe --always`")

# Prepare to touch version file if version changed
VERSION_NEW_TIME := $(CACHE_DIR)/new_version.time
VERSION_STATUS := $(shell echo $(VERSION) > $(VERSION_NEW_TIME))
VERSION_TIME := $(CACHE_DIR)/version.time
VERSION_INIT_STATUS := $(shell if test ! -e $(VERSION_TIME); then touch $(CACHE_DIR)/version.time; fi)
VERSION_DIFF_STATUS := $(shell if ! diff $(VERSION_NEW_TIME) $(VERSION_TIME) >/dev/null 2>&1; then cp $(VERSION_NEW_TIME) $(VERSION_TIME); fi)

endif # PROJECT_ROOT
