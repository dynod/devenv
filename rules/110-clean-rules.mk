# Clean rules
.PHONY: clean clean-out

ifdef PROJECT_ROOT

# Project full clean
clean:
	$(CLEAN_STATUS) -s "Clean project" -- git clean -fdX

# Project output clean
clean-out:
	$(CLEAN_STATUS) -s "Clean project output" -- rm -Rf $(OUTPUT_ROOT)

else # PROJECT_ROOT

# Workspace clean
clean:
	$(MULTI_STATUS) -s "Clean all projects"
	SUB_MAKE=1 $(REPO) forall -c "make $@"

clean-out:
	$(MULTI_STATUS) -s "Clean all projects output"
	SUB_MAKE=1 $(REPO) forall -c "make $@"

endif # PROJECT_ROOT
