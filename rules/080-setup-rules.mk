# Some rules for repo related stuff

# Repo init/sync rules
.PHONY: $(INIT_RULES) sync

$(INIT_RULES):
	# Init (for expected group, if any)
	$(SETUP_STATUS) -s "Initialize repo for $(GROUP_FROM_RULE) projects set" -- $(REPO) init -u $(REPO_URL) -m $(REPO_MANIFEST) -g default,$(GROUP_FROM_RULE) $(REPO_INIT_OPTIONS)
	# Generate branch manifest if needed
	$(BRANCH_MANIFEST_BUILD)

sync:
	# Sync + create local branch
	$(SYNC_STATUS) -s "Synchronize repo" -- $(REPO) sync -j $(CPU_COUNT) $(SYNC_OPTIONS)
	$(BRANCH_STATUS) -s "Create local branches" -- $(REPO) forall -c $(REPO_CHECKOUT_CMD)

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
# - generate config files
setup: sync sysdeps $(PYTHON_VENV) config
