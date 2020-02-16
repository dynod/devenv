# Repo definitions -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo root
REPO_ROOT := $(WORKSPACE_ROOT)/.repo

# Repo metadata
REPO_URL = $(shell $(REPO_HELPER) -r $(REPO_ROOT) --url)
REPO_MANIFEST = $(shell $(REPO_HELPER) -r $(REPO_ROOT) --manifest)
REPO_GROUPS = $(shell $(REPO_HELPER) -r $(REPO_ROOT) --groups)

# Repo setup rules
REPO_SETUP_RULES = $(foreach GROUP,$(REPO_GROUPS),setup-$(GROUP))

endif # WORKSPACE_ROOT
