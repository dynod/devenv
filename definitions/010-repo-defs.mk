# Repo definitions

# Repo root and tool
REPO_ROOT := $(WORKSPACE_ROOT)/.repo
REPO := $(REPO_ROOT)/repo/repo

# Cache dir will be in the repo root
CACHE_DIR := $(shell mkdir -p $(REPO_ROOT)/.cache && echo $(REPO_ROOT)/.cache)

# Cache for original manifest name
ORIGINAL_MANIFEST := $(CACHE_DIR)/original.manifest

# Repo metadata
REPO_URL := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --url)
REPO_GROUPS := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --groups)
REPO_CHECKOUT_CMD := $(REPO_HELPER) -r $(REPO_ROOT) --checkout
ifdef MANIFEST_RESET
REPO_MANIFEST := $(shell if test -e $(ORIGINAL_MANIFEST); then cat $(ORIGINAL_MANIFEST); else echo "manifest.xml"; fi)
else
REPO_MANIFEST := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --manifest)
endif

# All in one setup rules
SETUP_RULES := $(foreach GROUP,$(REPO_GROUPS),setup-$(GROUP))

# Init/Sync rules
INIT_RULES := $(foreach GROUP,$(REPO_GROUPS),init-$(GROUP))

# Get group from rule
GROUP_FROM_RULE = $(shell echo $@ | cut -d - -f 2)

# Projects
PROJECTS := $(foreach P,$(shell cat $(REPO_ROOT)/project.list),$(WORKSPACE_ROOT)/$(P))

# Check for branched manifest
ifdef MANIFEST_BRANCHES

# Persist original manifest
ORIGINAL_MANIFEST_STATUS := $(shell if test ! -e $(ORIGINAL_MANIFEST); then echo $(REPO_MANIFEST) > $(ORIGINAL_MANIFEST); fi)

# Generate branch manifest
BRANCH_MANIFEST_BUILD = $(FILE_STATUS) -s "Generating branch manifest" -- $(REPO_HELPER) -r $(REPO_ROOT) -b $(foreach B,$(MANIFEST_BRANCHES), --branch $(B))
SYNC_OPTIONS := --no-manifest-update

else # MANIFEST_BRANCHES

BRANCH_MANIFEST_BUILD := true

endif # MANIFEST_BRANCHES

ifdef PROJECT_ROOT

# Set project name
PROJECT_NAME := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --name)

endif # !PROJECT_ROOT

ifdef CI

# In CI, clone with depth 1
REPO_INIT_OPTIONS = --depth=1

endif # CI
