# Common rules file, including all the others...

# Include other more specific stuff
# Don't use make "wildcard" function, as it doesn't look to return files in alphabetical order
include $(shell ls $(TOOLS_ROOT)/rules/*.mk)
