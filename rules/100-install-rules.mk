# When stuff needs to be installed

# Python project with distribution
ifdef IS_PYTHON_PROJECT
ifdef PYTHON_DISTRIBUTION

.PHONY: install
install: $(PYTHON_DISTRIBUTION_INSTALL)

# Distribution venv install
$(PYTHON_DISTRIBUTION_INSTALL): $(PYTHON_DISTRIBUTION)
	$(IN_PYTHON_VENV)  $(INSTALL_STATUS) --lang python -s "Install Python distribution" -t install -- pip install $(PYTHON_DISTRIBUTION)
	touch $@

endif # PYTHON_DISTRIBUTION
endif # IS_PYTHON_PROJECT
