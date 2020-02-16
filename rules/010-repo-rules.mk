# Some rules for repo related stuff -- only works with full workspace
ifdef WORKSPACE_ROOT

# Repo setup rules
$(REPO_SETUP_RULES):
	group=$(subst setup-,,$@) && repo init -u $(REPO_URL) -m $(REPO_MANIFEST) -g $$group
	repo sync
	repo forall -c git branch -t master

endif # WORKSPACE_ROOT
