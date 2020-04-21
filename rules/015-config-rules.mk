# Rules for config generation
.PHONY: config

# Python project
ifdef IS_PYTHON_PROJECT

# Generate setup files
config: $(PYTHON_SETUP)

# Python setup.cfg
$(PYTHON_SETUP): $(PYTHON_SETUP_DEPS) $(VERSION_TIME)
	$(TOOLBOX_STATUS) -t config --lang python -s "Generate Python setup" -- $(SETTINGS_BUILDER) -o $@ $(PYTHON_SETUP_DEPS)

endif # IS_PYTHON_PROJECT
