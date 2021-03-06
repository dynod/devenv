# Rules to handle the test target

# Python project?
ifdef IS_PYTHON_PROJECT

# Somthing to test?
ifdef TEST_REPORT

# Add test target
.PHONY: tests
tests: build $(TEST_REPORT)

# Real tests run
$(TEST_REPORT): $(PYTHON_VENV) $(PYTHON_SETUP) $(SRC_FILES) $(TEST_FILES) $(TEST_TIME)
	rm -Rf $(TEST_ROOT)
	$(CROSS_FINGER_STATUS) -t pytest --lang python -s "Run Python tests"
	$(IN_PYTHON_VENV) $(HELPERS_ROOT)/incremental-pytest.sh $(TEST_TIME) $(TEST_REPORT)

# Default rule to rebuild test stamp file
$(TEST_TIME):
	touch $(TEST_TIME)

endif # TEST_REPORT

endif # IS_PYTHON_PROJECT

# Java project?
ifdef IS_JAVA_PROJECT

# Add test target
.PHONY: tests
tests: build gradle-tests
.PHONY: gradle-tests
gradle-tests:
	$(CROSS_FINGER_STATUS) -t tests --lang java -s "Delegate tests to gradle"
	$(PROJECT_ROOT)/gradlew test

endif # IS_JAVA_PROJECT
