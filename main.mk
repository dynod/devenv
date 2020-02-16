# Common definition file, including all the others...

# Silent mode
.SILENT:

# Shell is bash
SHELL := /bin/bash

# Include other more specific stuff
include $(wildcard $(TOOLS_ROOT)/definitions/*.mk)
