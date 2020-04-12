# Repo definitions -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo root and tool
REPO_ROOT := $(WORKSPACE_ROOT)/.repo
REPO := $(REPO_ROOT)/repo/repo

# Repo metadata
REPO_URL := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --url)
REPO_MANIFEST := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --manifest)
REPO_GROUPS := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --groups)
REPO_CHECKOUT_CMD := $(REPO_HELPER) -r $(REPO_ROOT) --checkout

# All in one setup rules
SETUP_RULES := $(foreach GROUP,$(REPO_GROUPS),setup-$(GROUP))

# Init/Sync rules
INIT_RULES := $(foreach GROUP,$(REPO_GROUPS),init-$(GROUP))

# Get group from rule
GROUP_FROM_RULE = $(shell echo $@ | cut -d - -f 2)

# Projects
PROJECTS := $(foreach P,$(shell cat $(REPO_ROOT)/project.list),$(WORKSPACE_ROOT)/$(P))

# Cache dir will be in the repo root
CACHE_DIR := $(shell mkdir -p $(REPO_ROOT)/.cache && echo $(REPO_ROOT)/.cache)

# Check for branched manifest
ifdef MANIFEST_BRANCHES

# Generate branch manifest
BRANCH_MANIFEST_BUILD := $(FILE_STATUS) -s "Generating branch manifest" $(REPO_HELPER) -b $(foreach B,$(MANIFEST_BRANCHES), --branch $(B))
SYNC_OPTIONS := --no-manifest-update

else # MANIFEST_BRANCHES

BRANCH_MANIFEST_BUILD := true

endif # MANIFEST_BRANCHES

else # !WORKSPACE_ROOT

# Projects
PROJECTS := $(PROJECT_ROOT) $(DEVENV_ROOT)

# Cache dir will be in the project git dir
CACHE_DIR := $(shell mkdir -p $(PROJECT_ROOT)/.git/.cache && echo $(PROJECT_ROOT)/.git/.cache)

endif # !WORKSPACE_ROOT
