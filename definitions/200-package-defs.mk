# Definitions for packaging

# Root for packaging stuff
PACKAGING_ROOT := $(OUTPUT_ROOT)/packaging

# For python projects only
ifdef PYTHON_PACKAGE

# venv for packaging
VENV_PACKAGING_ROOT := $(PACKAGING_ROOT)/venv
VENV_PACKAGING_ARCHIVE := $(PACKAGING_ROOT)/venv.tar.xz

endif # PYTHON_PACKAGE

# For deb packages only
ifdef DEB_PACKAGE_NAMES

# Build folder for deb
DEB_PACKAGING_ROOT := $(PACKAGING_ROOT)/deb

# Built deb packages
DEB_ARTIFACTS ?= $(ARTIFACTS_ROOT)/deb
DEB_PACKAGES := $(foreach N,$(DEB_PACKAGE_NAMES),$(DEB_ARTIFACTS)/$(N)_$(GIT_VERSION)_all.deb)

# Extract deb name from target
DEB_NAME = $(subst _$(GIT_VERSION)_all.deb,,$(shell basename $@))

# Shared skeleton files
DEB_DEVENV_SKEL := $(DEVENV_TEMPLATES)/deb/skel

# Project skeleton files (per package)
DEB_PROJECT_SKEL_ROOT ?= $(PROJECT_ROOT)/deb
DEB_PROJECT_SKEL = $(DEB_PROJECT_SKEL_ROOT)/$(DEB_NAME)/skel
DEB_PROJECT_RES = $(DEB_PROJECT_SKEL_ROOT)/$(DEB_NAME)/resources
DEB_PROJECT_DESCRIPTION = $(shell cat $(DEB_PROJECT_SKEL_ROOT)/$(DEB_NAME)/description.txt)

endif # DEB_PACKAGE_NAME
