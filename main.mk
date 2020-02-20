# Common definition file, including all the others...

# Silent mode
.SILENT:

# Shell is bash
SHELL := /bin/bash

# Some default PHONY targets
.PHONY: default all

# Include other more specific stuff
include $(wildcard $(TOOLS_ROOT)/definitions/*.mk)
