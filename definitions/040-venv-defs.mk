# Some definitions for Python virtual environment setup

# Virtual env path
PYTHON_VENV := venv

# Only if current project is a Python one
ifdef IS_PYTHON_PROJECT

# Python binary that will be used to setup the virtual environment
PYTHON_FOR_VENV ?= python3

# Requirements files (may be appended with project-specific requirements)
PYTHON_VENV_REQUIREMENTS ?= $(PYTHON_SHARED_SETTINGS)/requirements-tools.txt

endif # IS_PYTHON_PROJECT
