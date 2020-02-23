# Repo definitions -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo root and tool
REPO_ROOT := $(WORKSPACE_ROOT)/.repo
REPO := $(REPO_ROOT)/repo/repo

# Repo metadata
REPO_URL := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --url)
REPO_MANIFEST := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --manifest)
REPO_GROUPS := $(shell $(REPO_HELPER) -r $(REPO_ROOT) --groups)

# All in one setup rules
SETUP_RULES := $(foreach GROUP,$(REPO_GROUPS),setup-$(GROUP))

# Init/Sync rules
INIT_RULES := $(foreach GROUP,$(REPO_GROUPS),init-$(GROUP))

# Get group from rule
GROUP_FROM_RULE = $(shell echo $@ | cut -d - -f 2)

endif # WORKSPACE_ROOT
