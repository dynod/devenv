# Some rules for repo related stuff -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo setup rules
.PHONY: $(REPO_SETUP_RULES)
$(REPO_SETUP_RULES):
	group=$(subst setup-,,$@) && repo init -u $(REPO_URL) -m $(REPO_MANIFEST) -g default,$$group
	repo sync
	repo forall -c git checkout master

endif # WORKSPACE_ROOT
