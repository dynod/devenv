# System dependencies rules

.PHONY: sysdeps
sysdeps: $(SYSDEPS_TIME)

# System dependencies will be incrementally rescheduled if:
# - any requirement or database file changes
# - something was modified at system packages level
$(SYSDEPS_TIME): $(SYSDEP_DATABASE) $(SYSDEP_REQUIREMENTS) $(SYS_INSTALL_LOG)
	$(FLOPPY_STATUS) -s "Verifying system dependencies"
	$(SYSDEPS_HELPER) $(foreach D,$(SYSDEP_DATABASE),-d $(D)) $(SYSDEP_REQUIREMENTS)
	touch $(SYSDEPS_TIME)
