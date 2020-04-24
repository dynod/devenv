# Clean rules using git
.PHONY: clean

ifdef PROJECT_ROOT

# Project clean
clean:
	$(CLEAN_STATUS) -s "Clean project" -- git clean -fdX

else # PROJECT_ROOT

# Workspace clean
clean:
	$(MULTI_STATUS) -s "Clean all projects"
	SUB_MAKE=1 $(REPO) forall -c "make $@"

endif # PROJECT_ROOT
