#
# Main makefile for stuffnodes projects
#

# Determine workspace/project/tools root
ifneq ("$(wildcard $(CURDIR)/.repo)","")
WORKSPACE_ROOT := $(CURDIR)
else
ifneq ("$(wildcard $(CURDIR)/../.repo)","")
WORKSPACE_ROOT := $(CURDIR)/..
PROJECT_ROOT := $(CURDIR)
endif
endif
TOOLS_ROOT := $(WORKSPACE_ROOT)/tools

# Main makefile suite - defs
include $(TOOLS_ROOT)/main.mk

# Default target is help
default: help

# Main makefile suite - rules
include $(TOOLS_ROOT)/rules.mk
