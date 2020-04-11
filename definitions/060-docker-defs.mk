# Definitions for Docker images build

# Only in project mode
ifdef PROJECT_ROOT

# All Dockerfiles
DOCKERFILES := $(shell find $(PROJECT_ROOT) -name Dockerfile)

ifneq ($(DOCKERFILES),)
# This is a Docker project
IS_DOCKER_PROJECT := 1
endif

ifdef IS_DOCKER_PROJECT

# Docker image name from target
DOCKER_NAME_FROM_TARGET = $(subst docker-image-,,$(shell basename -s .time $@))

# All Docker images time files
DOCKERTIMES := $(foreach DF,$(DOCKERFILES),$(CACHE_DIR)/docker-image-$(shell basename `dirname $(DF)`).time)

endif # IS_DOCKER_PROJECT
endif # PROJECT_ROOT