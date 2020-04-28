# Definitions for Docker images build

# Only in project mode
ifdef PROJECT_ROOT
ifdef DOCKER_IMAGE_NAME

# All Dockerfiles
DOCKERFILE := $(wildcard $(PROJECT_ROOT)/Dockerfile)

ifneq ($(DOCKERFILE),)
# This is a Docker project
IS_DOCKER_PROJECT := 1
endif

ifdef IS_DOCKER_PROJECT

# Docker context dependencies is... well... the whole project
DOCKER_CONTEXT := $(shell find $(PROJECT_ROOT) -type f)

# All Docker images time files
DOCKERTIME := $(CACHE_DIR)/dockerimage.time

endif # IS_DOCKER_PROJECT
endif # DOCKER_IMAGE_NAME
endif # PROJECT_ROOT
