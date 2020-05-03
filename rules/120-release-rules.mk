# Rules to build a release manifest

ifdef PROJECT_ROOT
ifdef WORKSPACE_DEPS_MAP

# Release target for current project
.PHONY: release
release:
	$(FILE_STATUS) -s "Generate release manifest" -- $(REPO_HELPER) --release --dependencies $(WORKSPACE_DEPS_MAP)

endif # WORKSPACE_DEPS_MAP
endif # PROJECT_ROOT
