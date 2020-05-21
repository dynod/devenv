# Shared definitions for VS Code

# VS Code settings files
VSCODE_SETTINGS := $(DEVENV)/vscode

# All VS Code shared settings folders
ALL_VSCODE_SHARED_SETTINGS := $(foreach P,$(PROJECTS),$(P)/$(VSCODE_SETTINGS)/shared)

# Project specific defs
ifdef PROJECT_ROOT

# VS Code project settings files
VSCODE_PROJECT_SETTINGS := $(PROJECT_ROOT)/$(VSCODE_SETTINGS)

# VS Code settings folder
VSCODE_ROOT := $(PROJECT_ROOT)/.vscode

# Setting file
VSCODE_P_SETTINGS := $(VSCODE_ROOT)/settings.json

# Launch file
VSCODE_P_LAUNCH := $(VSCODE_ROOT)/launch.json

endif # PROJECT_ROOT
