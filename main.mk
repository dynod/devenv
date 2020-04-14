# Common definition file, including all the others...

# Silent mode
.SILENT:

# Shell is bash
SHELL := /bin/bash

# Include other more specific stuff
# Don't use make "wildcard" function, as it doesn't look to return files in alphabetical order
include $(shell ls $(DEVENV_ROOT)/definitions/*.mk)
