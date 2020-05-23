# Additional dependencies for settings, coming from workspace/project

ifdef IS_PYTHON_PROJECT

# Other setup.cfg stuff?
PYTHON_SETUP_DEPS += $(shell find $(ALL_PYTHON_SHARED_SETTINGS) $(PYTHON_PROJECT_SETTINGS) -maxdepth 1 -name 'setup.cfg' 2> /dev/null)

endif # IS_PYTHON_PROJECT

ifdef PROJECT_ROOT

# Other VS Code stuff?
VS_CODE_SETTINGS_DEPS += $(shell find $(ALL_VSCODE_SHARED_SETTINGS) $(VSCODE_PROJECT_SETTINGS) -maxdepth 1 -name 'settings.json' 2> /dev/null)
VS_CODE_LAUNCH_DEPS += $(shell find $(ALL_VSCODE_SHARED_SETTINGS) $(VSCODE_PROJECT_SETTINGS) -maxdepth 1 -name 'launch.json' 2> /dev/null)

endif # PROJECT_ROOT
