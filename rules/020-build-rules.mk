# Build rules

# All in one target
.PHONY: build

# Not in workspace
ifdef PROJECT_ROOT

# Needs at least config to be done
build: config

# Python project
ifdef IS_PYTHON_PROJECT

.PHONY: codeformat
codeformat: $(CODEFORMAT_TIME)
build: codeformat

# Format Python code
$(CODEFORMAT_TIME): $(PYTHON_VENV) $(SRC_FILES) $(TEST_FILES) $(PYTHON_GEN_FILES)
	$(PYTHON_CODE_FORMAT_CMD) $(SRC_FILES) $(TEST_FILES) $(PYTHON_GEN_FILES)
	touch $(CODEFORMAT_TIME)

.PHONY: flake8
flake8: $(FLAKE_REPORT)
build: flake8

# Static analysis with flake8
$(FLAKE_REPORT): $(PYTHON_VENV) $(PYTHON_SETUP) $(SRC_FILES) $(TEST_FILES)
	rm -Rf $(FLAKE_ROOT)
	mkdir -p $(FLAKE_ROOT)
	$(IN_PYTHON_VENV) $(EYE_STATUS) -t flake8 --lang python -s "Analyze Python code" -- flake8 $(SRC_FOLDER) $(TEST_FOLDER)

ifdef PYTHON_DISTRIBUTION

.PHONY: dist
dist: $(PYTHON_DISTRIBUTION)
build: dist

# Build distribution
$(PYTHON_DISTRIBUTION): $(PYTHON_VENV) $(PYTHON_SETUP) $(PYTHON_SETUP_EXE) $(SRC_FILES) $(PYTHON_GEN_FILES)
	rm -Rf $(PYTHON_ARTIFACTS)
	$(IN_PYTHON_VENV) $(BUILD_STATUS) --lang python -s "Build Python distribution" -t dist -- $(PYTHON_SETUP_EXE) sdist --dist-dir $(PYTHON_ARTIFACTS)

# Python executable file
$(PYTHON_SETUP_EXE): $(PYTHON_SETUP_TEMPLATE)
	cp $(PYTHON_SETUP_TEMPLATE) $(PYTHON_SETUP_EXE)
	chmod +x $(PYTHON_SETUP_EXE)

endif # PYTHON_DISTRIBUTION

endif # IS_PYTHON_PROJECT

# Java project
ifdef IS_JAVA_PROJECT

# Gradle build
.PHONY: jar
build: jar
jar:
	$(BUILD_STATUS) --lang java -s "Delegate build to gradle"
	$(PROJECT_ROOT)/gradlew $(GRADLE_BUILD_TARGET)

# Java library artifact
ifdef JAVA_LIB
build: $(JAVA_LIB)
$(JAVA_LIB): $(JAVA_BUILT_LIB) jar
	mkdir -p $(JAVA_ARTIFACTS)
	cp -p $(JAVA_BUILT_LIB) $(JAVA_LIB)
endif # JAVA_LIB

endif # IS_JAVA_PROJECT

endif # PROJECT_ROOT
