# Definitions for Docker images build

# Only in project mode
ifdef PROJECT_ROOT
ifdef DOCKER_IMAGE_NAME

# Context folder
DOCKER_CONTEXT ?= $(PROJECT_ROOT)

# Dockerfile from context
DOCKERFILE := $(wildcard $(DOCKER_CONTEXT)/Dockerfile)

ifneq ($(DOCKERFILE),)
# This is a Docker project
IS_DOCKER_PROJECT := 1
endif

ifdef IS_DOCKER_PROJECT

# Docker context dependencies from context folder
DOCKER_CONTEXT_FILES := $(shell find $(DOCKER_CONTEXT) -type f)

# Docker image build/push time files
DOCKERTIME := $(CACHE_DIR)/dockerimage.time
DOCKERPUSHTIME := $(CACHE_DIR)/dockerpush.time

endif # IS_DOCKER_PROJECT
endif # DOCKER_IMAGE_NAME
endif # PROJECT_ROOT
