#
# Main makefile for dynod projects
#

# Determine workspace/project/tools root
ifneq ("$(wildcard $(CURDIR)/.repo)","")
WORKSPACE_ROOT := $(CURDIR)
else
ifneq ("$(wildcard $(CURDIR)/../../.repo)","")
WORKSPACE_ROOT := $(CURDIR)/../..
PROJECT_ROOT := $(CURDIR)

endif
endif
DEVENV_ROOT := $(WORKSPACE_ROOT)/tools/devenv

# Main makefile suite - defs
include $(DEVENV_ROOT)/main.mk

# Default target is help
default: help

# Main makefile suite - rules
include $(DEVENV_ROOT)/rules.mk
