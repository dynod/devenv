# Shared definitions for Java

# Project specific defs
ifdef PROJECT_ROOT

# Default gradle source folder
JAVA_SRC_FOLDER ?= $(SRC_FOLDER)/main/java

# Default gradle test folder
JAVA_TEST_FOLDER ?= $(SRC_FOLDER)/test/java

# Default gradle output folder
JAVA_OUTPUT_ROOT ?= $(PROJECT_ROOT)/build

# Java source files
JAVA_SRC_FILES := $(shell find $(JAVA_SRC_FOLDER) -name '*.java' 2>/dev/null)

# Is Java project?
ifneq ($(JAVA_SRC_FILES),)
IS_JAVA_PROJECT := 1

# Java artifacts
JAVA_ARTIFACTS ?= $(ARTIFACTS_ROOT)/java

# Java library
ifdef JAVA_LIB_NAME

# Gradle output
JAVA_BUILT_LIB := $(JAVA_OUTPUT_ROOT)/libs/$(JAVA_LIB_NAME).jar

# Artifact file
JAVA_LIB := $(JAVA_ARTIFACTS)/$(JAVA_LIB_NAME)-$(GIT_VERSION).jar

endif # JAVA_LIB_NAME

endif # IS_JAVA_PROJECT
endif # PROJECT_ROOT
