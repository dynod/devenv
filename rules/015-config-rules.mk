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

# Simple project
ifdef PROJECT_ROOT

ifneq ($(VS_CODE_SETTINGS_DEPS),)

config: $(VSCODE_P_SETTINGS)

# VS Code settings
$(VSCODE_P_SETTINGS): $(VS_CODE_SETTINGS_DEPS)
	$(TOOLBOX_STATUS) -t config -s "Generate VS Code settings file" -- $(SETTINGS_BUILDER) -o $@ $(VS_CODE_SETTINGS_DEPS)

endif # VS_CODE_SETTINGS_DEPS

ifneq ($(VS_CODE_LAUNCH_DEPS),)

# VS Code launch
config: $(VSCODE_P_LAUNCH)

$(VSCODE_P_LAUNCH): $(VS_CODE_LAUNCH_DEPS)
	$(TOOLBOX_STATUS) -t config -s "Generate VS Code launch file" -- $(SETTINGS_BUILDER) -o $@ $(VS_CODE_LAUNCH_DEPS)

endif # VS_CODE_LAUNCH_DEPS

else # PROJECT_ROOT

ifdef CI_PROJECT_ROOT
# At workspace root, trigger config build only in CI_PROJECT_ROOT
BUILD_CI_VENV = 1
endif # !CI_PROJECT_ROOT

ifdef BUILD_CI_VENV

config:
	$(MULTI_STATUS) -s "Generate config files for CI built project ($(CI_PROJECT))"
	SUB_MAKE=1 make -C $(CI_PROJECT_ROOT) $@

else # BUILD_CI_VENV

# Other cases (at workspace root but not in CI)
config: stub

endif # BUILD_CI_VENV

endif # PROJECT_ROOT
