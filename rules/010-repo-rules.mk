# Some rules for repo related stuff -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo init/sync rules
.PHONY: $(SYNC_RULES) $(INIT_RULES) sync

$(SYNC_RULES):
	# Has to do it this crappy way, because patterns (e.g. sync-%: init-%) don't work with PHONY targets
	make init-$(GROUP_FROM_RULE) sync

$(INIT_RULES):
	# Init (for expected group, if any)
	$(REPO) init -u $(REPO_URL) -m $(REPO_MANIFEST) -g default,$(GROUP_FROM_RULE)

sync:
	# Sync + create local branch
	$(REPO) sync
	$(REPO) forall -c git checkout master

# All in one setup rules
.PHONY: $(SETUP_RULES) setup
$(SETUP_RULES):
	# Has to do it this crappy way, because patterns (e.g. setup-%: sync-%) don't work with PHONY targets
	make sync-$(GROUP_FROM_RULE)

# Setup for current group
setup: sync

endif # WORKSPACE_ROOT
