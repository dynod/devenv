# Code generation definitions

# Folder holding the API files
PROTO_FOLDER ?= $(PROJECT_ROOT)/protos

# Is PROTO_PACKAGE defined?
ifdef PROTO_PACKAGE

# API files
PROTO_FILES := $(shell find $(PROTO_FOLDER)/$(PROTO_PACKAGE) -name '*.proto' 2>/dev/null)

# Is code generation supported?
ifneq ($(PROTO_FILES),)
IS_CODEGEN_PROJECT := 1

# Are proto dependencies declared?
ifdef PROTO_DEPS

# Compute additional options for code generation
PROTO_DEPS_OPTIONS := $(foreach D,$(PROTO_DEPS),--proto_path $(D))

endif # PROTO_DEPS

endif # IS_CODEGEN_PROJECT

endif # PROTO_PACKAGE
