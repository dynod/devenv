# Shared definitions for Java

# Project specific defs
ifdef PROJECT_ROOT

# Default gradle source folder
JAVA_SRC_FOLDER ?= $(SRC_FOLDER)/main/java

# Default gradle test folder
JAVA_TEST_FOLDER ?= $(SRC_FOLDER)/test/java

# Java source files
JAVA_SRC_FILES := $(shell find $(JAVA_SRC_FOLDER) -name '*.java' 2>/dev/null)

# Is Java project?
ifneq ($(JAVA_SRC_FILES),)
IS_JAVA_PROJECT := 1

# Gradle target for build
GRADLE_BUILD_TARGET ?= jar

# Java artifacts
JAVA_ARTIFACTS ?= $(ARTIFACTS_ROOT)/java

# Java library
ifdef JAVA_LIB_NAME

# Default extension is jar
JAVA_LIB_EXT ?= jar

# Default gradle liboutput folder
JAVA_LIB_OUTPUT_ROOT ?= $(PROJECT_ROOT)/build/libs

# Gradle output
JAVA_BUILT_LIB ?= $(JAVA_LIB_OUTPUT_ROOT)/$(JAVA_LIB_NAME).$(JAVA_LIB_EXT)

# Artifact file
JAVA_LIB := $(JAVA_ARTIFACTS)/$(JAVA_LIB_NAME)-$(GIT_VERSION).$(JAVA_LIB_EXT)

endif # JAVA_LIB_NAME

endif # IS_JAVA_PROJECT
endif # PROJECT_ROOT
