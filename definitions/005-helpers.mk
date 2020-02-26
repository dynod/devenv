# Helpers location
HELPERS_ROOT := $(TOOLS_ROOT)/helpers

# Helper for repo metadata
REPO_HELPER := $(HELPERS_ROOT)/repo.py

# Helper for status display
STATUS_HELPER := $(HELPERS_ROOT)/status.py

# Build logs (clean on each make call)
BUILD_LOGS ?= /tmp/build-logs
ifdef NO_BUILD_LOGS_CLEAN
BUILD_LOGS_RESOLVED = $(BUILD_LOGS)
else
BUILD_LOGS_RESOLVED = $(shell rm -Rf $(BUILD_LOGS) && echo $(BUILD_LOGS))
endif

# Status macros
ifdef WORKSPACE_ROOT
ifdef PROJECT_ROOT
STATUS = $(STATUS_HELPER) -w $(WORKSPACE_ROOT) -p $(PROJECT_ROOT) -t $@ -o $(BUILD_LOGS_RESOLVED)
else # PROJECT_ROOT
STATUS = $(STATUS_HELPER) -w $(WORKSPACE_ROOT) -p $(WORKSPACE_ROOT) -t $@ -o $(BUILD_LOGS_RESOLVED)
endif
else # WORKSPACE_ROOT
STATUS = $(STATUS_HELPER) -p $(PROJECT_ROOT) -t $@ -o $(BUILD_LOGS_RESOLVED)
endif
BUILD_STATUS = $(STATUS) -i build
CLEAN_STATUS = $(STATUS) -i clean
SETUP_STATUS = $(STATUS) -i setup
GIFT_STATUS = $(STATUS) -i gift
SLEEP_STATUS = $(STATUS) -i sleep
STUB_STATUS = $(SLEEP_STATUS) -s "Nothing to do"
MULTI_STATUS = $(STATUS) -i multi
SYNC_STATUS = $(STATUS) -i sync
BRANCH_STATUS = $(STATUS) -i branch
