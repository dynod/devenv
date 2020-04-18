# Some definitions for Python virtual environment setup

# Virtual env path
PYTHON_VENV := venv

# Only if current project is a Python one
ifdef IS_PYTHON_PROJECT

# Python binary that will be used to setup the virtual environment
PYTHON_FOR_VENV ?= python3

# List project requirements files + shared ones
PYTHON_VENV_REQUIREMENTS := $(shell find $(ALL_PYTHON_SHARED_SETTINGS) $(PYTHON_PROJECT_SETTINGS) -maxdepth 1 -name '*.txt' 2> /dev/null)

# Run command in venv
IN_PYTHON_VENV := source $(PYTHON_VENV)/bin/activate && 

endif # IS_PYTHON_PROJECT
