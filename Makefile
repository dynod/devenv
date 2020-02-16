#
# Main makefile for stuffnodes projects
#

# Determine workspace root
ifneq ("$(wildcard $(CURDIR)/.repo)","")
WORKSPACE_ROOT := $(CURDIR)
else
ifneq ("$(wildcard $(CURDIR)/../.repo)","")
WORKSPACE_ROOT := $(CURDIR)/..
endif
endif
TOOLS_ROOT := $(WORKSPACE_ROOT)/tools

# Main makefile suite
include $(TOOLS_ROOT)/main.mk
include $(TOOLS_ROOT)/rules.mk
