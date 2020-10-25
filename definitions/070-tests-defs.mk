# Some test related definitions

# Python project?
ifdef IS_PYTHON_PROJECT

# All Python test files
TEST_FILES := $(shell find $(TEST_FOLDER) -name '*.py' 2>/dev/null)

# Flake8 report
FLAKE_ROOT := $(OUTPUT_ROOT)/flake-report
FLAKE_REPORT := $(FLAKE_ROOT)/index.html
FLAKE_INPUT := $(SRC_FOLDER)

# Something to test
ifneq ($(TEST_FILES),)

# Also analyse test files
FLAKE_INPUT += $(TEST_FOLDER)

# Default count of parallel test processes: auto (== CPU count)
PYTEST_NUM_PROCESSES ?= auto

# Add test configuration in setup
PYTHON_SETUP_DEPS += $(PYTHON_DEVENV_TEMPLATES)/setup-test.cfg

# Contribute to VS Code settings as well
VS_CODE_SETTINGS_DEPS += $(PYTHON_DEVENV_TEMPLATES)/settings-python-tests.json
VS_CODE_LAUNCH_DEPS += $(PYTHON_DEVENV_TEMPLATES)/launch-python-tests.json

ifdef IS_CODEGEN_PROJECT
# Some stuff needs to be ignored in the settings (because in generated code)
PYTHON_SETUP_DEPS += $(PYTHON_DEVENV_TEMPLATES)/setup-test-codegen.cfg
endif # IS_CODEGEN_PROJECT

# Tests report
TEST_ROOT := $(OUTPUT_ROOT)/tests
TEST_REPORT := $(TEST_ROOT)/report.xml

# Time file for incremental tests behavior
TEST_TIME := $(CACHE_DIR)/tests.time

endif # TEST_FILES

endif # IS_PYTHON_PROJECT

# Java project?
ifdef IS_JAVA_PROJECT

# All Java test files
JAVA_TEST_FILES := $(shell find $(JAVA_TEST_FOLDER) -name '*.java' 2>/dev/null)

endif # IS_JAVA_PROJECT
