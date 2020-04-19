# Build rules

# All in one target
.PHONY: build

# Python project
ifdef IS_PYTHON_PROJECT

.PHONY: codeformat
codeformat: $(CODEFORMAT_TIME)
build: codeformat

# Format Python code
$(CODEFORMAT_TIME): $(PYTHON_VENV) $(SRC_FILES) $(TEST_FILES) $(PYTHON_GEN_FILES)
	$(IN_PYTHON_VENV) $(LIPSTICK_STATUS) --lang python -s "Format code" black --line-length 160 $?
	touch $(CODEFORMAT_TIME)

.PHONY: flake8
flake8: $(FLAKE_REPORT)
build: flake8

# Static analysis with flake8
$(FLAKE_REPORT): $(PYTHON_VENV) $(PYTHON_SETUP) $(SRC_FILES) $(TEST_FILES)
	rm -Rf $(FLAKE_ROOT)
	mkdir -p $(FLAKE_ROOT)
	$(IN_PYTHON_VENV) $(EYE_STATUS) -t flake8 --lang python -s "Analyzing Python code" flake8 $(SRC_FOLDER) $(TEST_FOLDER)

ifdef PYTHON_DISTRIBUTION

.PHONY: dist
dist: $(PYTHON_DISTRIBUTION)
build: dist

# Build distribution
$(PYTHON_DISTRIBUTION): $(PYTHON_VENV) $(PYTHON_SETUP) $(SRC_FILES) $(PYTHON_GEN_FILES)
	rm -Rf $(PYTHON_ARTIFACTS)
	$(IN_PYTHON_VENV) $(BUILD_STATUS) --lang python -s "Build Python distribution" -t dist ./setup.py sdist --dist-dir $(PYTHON_ARTIFACTS)

.PHONY: install
install: $(PYTHON_DISTRIBUTION_INSTALL)
build: install

# Distribution venv install
$(PYTHON_DISTRIBUTION_INSTALL): $(PYTHON_DISTRIBUTION)
	$(IN_PYTHON_VENV)  $(INSTALL_STATUS) --lang python -s "Install Python distribution" -t install pip install $(PYTHON_DISTRIBUTION)
	touch $@

endif # PYTHON_DISTRIBUTION

endif # IS_PYTHON_PROJECT
