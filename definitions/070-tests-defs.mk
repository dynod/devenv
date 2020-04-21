# Some test related definitions

# Python project?
ifdef IS_PYTHON_PROJECT

# Assume tests are localted in "tests" folder by default
# (can be overriden)
TEST_FOLDER ?= $(SRC_FOLDER)/tests/

# All Python test files
TEST_FILES := $(shell find $(TEST_FOLDER) -name '*.py' 2>/dev/null)

# Flake8 report
FLAKE_ROOT := $(OUTPUT_ROOT)/flake-report
FLAKE_REPORT := $(FLAKE_ROOT)/index.html

# Something to test
ifneq ($(TEST_FILES),)

# Add test configuration in setup
PYTHON_SETUP_DEPS += $(PYTHON_DEVENV_TEMPLATES)/setup-test.cfg

# Tests report
TEST_ROOT := $(OUTPUT_ROOT)/tests
TEST_REPORT := $(TEST_ROOT)/report.xml

# Time file for incremental tests behavior
TEST_TIME := $(CACHE_DIR)/tests.time

endif # TEST_FILES

endif # IS_PYTHON_PROJECT
