# Test Makefile

# Fake some paths
PROJECT_ROOT=$(CURDIR)
WORKSPACE_ROOT=$(CURDIR)/../..

# DEVENV_ROOT to be provided dynamically from Python test code

# Fake version
VERSION := 1.2.3

# Package name
PYTHON_PACKAGE := foo-stuff

include $(DEVENV_ROOT)/main.mk

default: stub

include $(DEVENV_ROOT)/rules.mk
