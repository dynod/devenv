# Rules to build packages

# For python projects only
ifdef PYTHON_PACKAGE

# Venv package ready for packaging
.PHONY: venv-package
venv-package: $(VENV_PACKAGING_ARCHIVE)

$(VENV_PACKAGING_ARCHIVE): $(PYTHON_DISTRIBUTION)
	# Clean
	rm -Rf $(VENV_PACKAGING_ARCHIVE) $(VENV_PACKAGING_ROOT)

	# Build venv
	export PYTHON_VENV_EXTRA_ARGS="$(PYTHON_VENV_EXTRA_ARGS)" && \
	export PROJECT_ROOT="$(PROJECT_ROOT)" && \
	export SETUP_VENV_TARGET=venv-package && \
	$(GIFT_STATUS) -t venv-package --lang python -s "Build Python virtual environment for packaging" && \
	$(HELPERS_ROOT)/setup-venv.sh \
		$(PYTHON_FOR_VENV) \
		$(VENV_PACKAGING_ROOT) \
		$(PYTHON_PACKAGE)==$(VERSION)

	# Turn hard coded venv path into a replaceable token
	find $(VENV_PACKAGING_ROOT) -type f -print0 | while IFS= read -r -d '' file; do sed -i "$$file" -e "s|$(VENV_PACKAGING_ROOT)|{VENV}|g"; done

	# Clean cache
	rm -Rf `find $(VENV_PACKAGING_ROOT) -type d -name __pycache__`

	# Build archive for venv
	tar caf $(VENV_PACKAGING_ARCHIVE) -C $(VENV_PACKAGING_ROOT) .

endif # PYTHON_PACKAGE

# For Debian packages
ifdef DEB_PACKAGES

# Deb packages rules
.PHONY: deb
deb: $(DEB_PACKAGES)

$(DEB_PACKAGES):
	# Clean artifacts
	mkdir -p $(DEB_ARTIFACTS)
	rm -f $(DEB_ARTIFACTS)/$(DEB_NAME)_$(GIT_VERSION)_*

	# Build debian package
	export DEB_DEVENV_SKEL=$(DEB_DEVENV_SKEL) && \
	export DEB_WORKSPACE_SKEL=$(DEB_WORKSPACE_SKEL) && \
	$(GIFT_STATUS) -t deb --lang linux -s "Build $(DEB_NAME) debian package (`basename $@`)" -- \
		$(HELPERS_ROOT)/build-deb.sh \
			"$(DEB_PACKAGING_ROOT)/$(DEB_NAME)" \
			"$(DEB_NAME)" \
			"$(GIT_VERSION)" \
			"$(DEB_PROJECT_DESCRIPTION)" \
			"$(DEB_PROJECT_SKEL)" \
			"$(DEB_PROJECT_RES)" \
			"$(DEB_DIST_FILES_FOR_$(DEB_NAME))"

	# Copy artifacts
	cp \
		"$(DEB_PACKAGING_ROOT)/$(DEB_NAME)"/`basename $@` \
		"$(DEB_PACKAGING_ROOT)/$(DEB_NAME)"/$(DEB_NAME)_$(GIT_VERSION)_amd64* \
		$(DEB_ARTIFACTS)

# For python projects only
ifdef PYTHON_PACKAGE

# For Python projects, make deb package depending on venv package
$(DEB_PACKAGES): $(VENV_PACKAGING_ARCHIVE)

endif # PYTHON_PACKAGE

endif # DEB_PACKAGES
