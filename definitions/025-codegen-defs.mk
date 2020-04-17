# Code generation definitions

# Folder holding the API files
PROTO_FOLDER ?= $(PROJECT_ROOT)/protos

# API files
PROTO_FILES := $(shell find $(PROTO_FOLDER) -name *.proto)

# Is code generation supported?
ifneq ($(PROTO_FILES),)
IS_CODEGEN_PROJECT := 1

endif # IS_CODEGEN_PROJECT
