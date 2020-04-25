# Rules for config generation
.PHONY: config

# Python project
ifdef IS_PYTHON_PROJECT

# Generate setup files
config: $(PYTHON_SETUP)

# Python setup.cfg
$(PYTHON_SETUP): $(PYTHON_SETUP_DEPS) $(VERSION_TIME)
	$(TOOLBOX_STATUS) -t config --lang python -s "Generate Python setup" -- $(SETTINGS_BUILDER) -o $@ $(PYTHON_SETUP_DEPS)

ifdef PYTHON_SETUP_REQUIREMENTS
# Setup.cfg also depends on requirements list
$(PYTHON_SETUP): $(PYTHON_MAIN_REQUIREMENTS)
endif

endif # IS_PYTHON_PROJECT
