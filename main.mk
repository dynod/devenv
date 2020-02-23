# Common definition file, including all the others...

# Silent mode
.SILENT:

# Shell is bash
SHELL := /bin/bash

# Some default PHONY targets
.PHONY: default all

# Include other more specific stuff
# Don't use make "wildcard" function, as it doesn't look to return files in alphabetical order
include $(shell ls $(TOOLS_ROOT)/definitions/*.mk)
