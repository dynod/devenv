# Some definitions for CI
ifdef CI
ifdef CI_PROJECT
ifndef PROJECT_ROOT

# At workspace root, reckon CI project path
CI_PROJECT_ROOT := $(shell $(REPO_HELPER) --path $(CI_PROJECT))

endif # PROJECT_ROOT
endif # CI_PROJECT
endif # CI
