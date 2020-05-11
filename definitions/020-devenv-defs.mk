# Definitions for development environment settings

DEVENV := .devenv

# Project specific defs
ifdef PROJECT_ROOT

# Common devenv folder
PROJECT_DEVENV_SETTINGS := $(PROJECT_ROOT)/$(DEVENV)

# Source folder
SRC_FOLDER ?= $(PROJECT_ROOT)/src

# Assume tests are located in "src/tests" folder by default
TEST_FOLDER ?= $(SRC_FOLDER)/tests

# Output folder
OUTPUT_ROOT ?= $(PROJECT_ROOT)/out

# Artifacts folder
ARTIFACTS_ROOT ?= $(OUTPUT_ROOT)/artifacts

# Version
VERSION ?= $(shell $(HELPERS_ROOT)/scm-version.sh)

# Prepare to touch version file if version changed
VERSION_NEW_TIME := $(CACHE_DIR)/new_version.time
VERSION_STATUS := $(shell echo $(VERSION) > $(VERSION_NEW_TIME))
VERSION_TIME := $(CACHE_DIR)/version.time
VERSION_INIT_STATUS := $(shell if test ! -e $(VERSION_TIME); then touch $(CACHE_DIR)/version.time; fi)
VERSION_DIFF_STATUS := $(shell if ! diff $(VERSION_NEW_TIME) $(VERSION_TIME) >/dev/null 2>&1; then cp $(VERSION_NEW_TIME) $(VERSION_TIME); fi)

# Shared workspace settings
ifdef WORKSPACE_PROJECT_ROOT
ifneq ($(wildcard $(WORKSPACE_PROJECT_ROOT)/deps.json),)

# Map of inter-project dependencies within the workspace
WORKSPACE_DEPS_MAP := $(WORKSPACE_PROJECT_ROOT)/deps.json

# List of current project dependencies paths
PROJECT_DEPS_PATHS := $(shell $(REPO_HELPER) -p @deps --dependencies $(WORKSPACE_DEPS_MAP))

endif # WORKSPACE_DEPS_MAP
endif # WORKSPACE_PROJECT_ROOT

endif # PROJECT_ROOT
