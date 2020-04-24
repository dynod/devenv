#
# Main makefile for dynod projects
#

WORKSPACE_ROOT := $(CURDIR)/../..
PROJECT_ROOT := $(CURDIR)

# Be backward compatible with python 3.6 for tools
PYTHON_FOR_VENV := python3.6

# Main makefile suite - defs
include $(WORKSPACE_ROOT)/.workspace/main.mk

# Default target is build
default: build

# Main makefile suite - rules
include $(WORKSPACE_ROOT)/.workspace/rules.mk
