# Repo definitions

# Repo root and tool
REPO_ROOT := $(WORKSPACE_ROOT)/.repo
REPO := $(REPO_ROOT)/repo/repo

# Cache directories will be in the repo root
CACHE_SHARED_DIR := $(shell mkdir -p $(REPO_ROOT)/.cache && echo $(REPO_ROOT)/.cache)

# Cache for original manifest name
ORIGINAL_MANIFEST := $(CACHE_SHARED_DIR)/original.manifest

# Helper for repo metadata
REPO_HELPER := $(HELPERS_ROOT)/repo.py -r $(REPO_ROOT)

# Repo metadata
REPO_URL := $(shell $(REPO_HELPER) --url)
REPO_GROUPS := $(shell $(REPO_HELPER) --groups)
REPO_CHECKOUT_CMD := $(REPO_HELPER) --checkout
ifdef MANIFEST_RESET
REPO_MANIFEST := $(shell if test -e $(ORIGINAL_MANIFEST); then cat $(ORIGINAL_MANIFEST); else echo "manifest.xml"; fi)
else
REPO_MANIFEST := $(shell $(REPO_HELPER) --manifest)
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
BRANCH_MANIFEST_OPTIONS += $(foreach B,$(MANIFEST_BRANCHES), --branch $(B))
endif
ifdef MANIFEST_TAGS
BRANCH_MANIFEST_OPTIONS += $(foreach B,$(MANIFEST_TAGS), --tag $(B))
endif

ifdef BRANCH_MANIFEST_OPTIONS

# Persist original manifest
ORIGINAL_MANIFEST_STATUS := $(shell if test ! -e $(ORIGINAL_MANIFEST); then echo $(REPO_MANIFEST) > $(ORIGINAL_MANIFEST); fi)

# Generate branch manifest
BRANCH_MANIFEST_BUILD = $(FILE_STATUS) -s "Generating branch manifest" -- $(REPO_HELPER) -b $(BRANCH_MANIFEST_OPTIONS)
SYNC_OPTIONS := --no-manifest-update

else # !BRANCH_MANIFEST_OPTIONS

BRANCH_MANIFEST_BUILD := true

endif # !BRANCH_MANIFEST_OPTIONS

ifdef PROJECT_ROOT

# Set project name
PROJECT_NAME := $(shell $(REPO_HELPER) --name)

# Project cache
CACHE_DIR := $(shell mkdir -p $(CACHE_SHARED_DIR)/$(PROJECT_NAME) && echo $(CACHE_SHARED_DIR)/$(PROJECT_NAME))

endif # !PROJECT_ROOT

ifdef CI

# In CI, clone with depth 1
REPO_INIT_OPTIONS = --depth=1

endif # CI
