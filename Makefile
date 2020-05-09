#
# Main makefile for dynod projects
#

WORKSPACE_ROOT := $(CURDIR)/../..
PROJECT_ROOT := $(CURDIR)

# Main makefile suite - defs
include $(WORKSPACE_ROOT)/.workspace/main.mk

# Default target is build
default: build

# Main makefile suite - rules
include $(WORKSPACE_ROOT)/.workspace/rules.mk
