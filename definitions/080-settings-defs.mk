# Additional dependencies for settings, coming from workspace/project

ifdef IS_PYTHON_PROJECT

# Other setup.cfg stuff?
PYTHON_SETUP_DEPS += $(shell find $(ALL_PYTHON_SHARED_SETTINGS) $(PYTHON_PROJECT_SETTINGS) -maxdepth 1 -name 'setup.cfg' 2> /dev/null)

endif # IS_PYTHON_PROJECT
