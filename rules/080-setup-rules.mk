# Some rules for repo related stuff -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo init/sync rules
.PHONY: $(INIT_RULES) sync

$(INIT_RULES):
	# Init (for expected group, if any)
	$(SETUP_STATUS) -s "Initialize repo for $(GROUP_FROM_RULE) projects set" $(REPO) init -u $(REPO_URL) -m $(REPO_MANIFEST) -g default,$(GROUP_FROM_RULE)

sync:
	# Sync + create local branch
	$(SYNC_STATUS) -s "Synchronize repo" $(REPO) sync
	$(BRANCH_STATUS) -s "Create local branches" $(REPO) forall -c git checkout master

# All in one setup rules (= init + setup)
.PHONY: $(SETUP_RULES) setup
$(SETUP_RULES):
	# Has to do it this crappy way, because patterns (e.g. setup-%: init-%) don't work with PHONY targets
	$(SETUP_STATUS) -s "Setup workspace for $(GROUP_FROM_RULE) projects set"
	SUB_MAKE=1 make init-$(GROUP_FROM_RULE) setup

# Setup once the group is initialized:
# - synchronize repo and create local branches
# - check system dependencies
# - prepare Python Virtual env (if any)
setup: sync sysdeps $(PYTHON_VENV)

endif # WORKSPACE_ROOT
