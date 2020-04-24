# Shared definitions for Python

# Python settings files
PYTHON_SETTINGS := $(DEVENV)/python

# All Python shared settings folders
ALL_PYTHON_SHARED_SETTINGS := $(foreach P,$(PROJECTS),$(P)/$(PYTHON_SETTINGS)/shared)

# Various templates coming from devenv
PYTHON_DEVENV_TEMPLATES := $(DEVENV_ROOT)/templates

# Project specific defs
ifdef PROJECT_ROOT

# Python project settings files
PYTHON_PROJECT_SETTINGS := $(PROJECT_ROOT)/$(PYTHON_SETTINGS)

# Python source files
PYTHON_SRC_FILES := $(shell find $(SRC_FOLDER) -name '*.py' 2>/dev/null)

# Is Python project?
ifneq ($(PYTHON_SRC_FILES),)
IS_PYTHON_PROJECT := 1

# All Python source files
SRC_FILES := $(PYTHON_SRC_FILES)

# Setup config file
PYTHON_SETUP := $(PROJECT_ROOT)/setup.cfg

# Need at least basic settings (flake8, isort, ...) in setup
PYTHON_SETUP_DEPS += $(PYTHON_DEVENV_TEMPLATES)/setup.cfg

# Setup executable file (+template)
PYTHON_SETUP_EXE := $(PROJECT_ROOT)/setup.py
PYTHON_SETUP_TEMPLATE := $(PYTHON_DEVENV_TEMPLATES)/setup.py

# Code format command
PYTHON_CODE_FORMAT_CMD = $(IN_PYTHON_VENV) $(LIPSTICK_STATUS) --lang python -s "Format code" -- black --line-length 160

# Python artifacts
PYTHON_ARTIFACTS ?= $(ARTIFACTS_ROOT)/python

# Python distribution
ifdef PYTHON_PACKAGE
PYTHON_DISTRIBUTION := $(PYTHON_ARTIFACTS)/$(PYTHON_PACKAGE)-$(VERSION).tar.gz

# Add some other stuff to setup.cfg
PYTHON_SETUP_DEPS += $(PYTHON_DEVENV_TEMPLATES)/setup-build.cfg

endif

# If code generation required?
ifdef IS_CODEGEN_PROJECT

PYTHON_GEN_FOLDER := $(SRC_FOLDER)/$(PROTO_PACKAGE)

# List Python generated files
PYTHON_GEN_INIT := $(PYTHON_GEN_FOLDER)/__init__.py
PYTHON_GEN_FILES := \
	$(foreach PROTO,$(PROTO_FILES),$(SRC_FOLDER)/$(subst $(PROTO_FOLDER)/,,$(subst .proto,,$(PROTO)))_pb2.py) \
	$(PYTHON_GEN_INIT)

# Some stuff needs to be ignored in the settings
PYTHON_SETUP_DEPS += $(PYTHON_DEVENV_TEMPLATES)/setup-flake-codegen.cfg

endif # IS_CODEGEN_PROJECT

# Code format time stamp
CODEFORMAT_TIME := $(CACHE_DIR)/codeformat.time

endif # IS_PYTHON_PROJECT

endif # PROJECT_ROOT
