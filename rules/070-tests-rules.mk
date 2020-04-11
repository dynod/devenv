# Rules to handle the test target

# Python project?
ifdef IS_PYTHON_PROJECT

# Add test target
.PHONY: tests flake8
tests: $(FLAKE_REPORT) $(TEST_REPORT)
flake8: $(FLAKE_REPORT)

# Static analysis with flake8
$(FLAKE_REPORT): $(PYTHON_VENV) $(PYTHON_SETUP) $(SRC_FILES) $(TEST_FILES)
	rm -Rf $(FLAKE_ROOT)
	mkdir -p $(FLAKE_ROOT)
	$(IN_PYTHON_VENV) $(EYE_STATUS) -t flake8 --lang python -s "Analyzing Python code" flake8 $(SRC_FOLDER) $(TEST_FOLDER)

# Real tests run
$(TEST_REPORT): $(PYTHON_VENV) $(PYTHON_SETUP) $(SRC_FILES) $(TEST_FILES) $(TEST_TIME)
	rm -Rf $(TEST_ROOT)
	$(CROSS_FINGER_STATUS) -t pytest --lang python -s "Running Python tests"
	$(IN_PYTHON_VENV) $(HELPERS_ROOT)/incremental-pytest.sh $(TEST_TIME) $(TEST_REPORT)

# Default rule to rebuild test stamp file
$(TEST_TIME):
	touch $(TEST_TIME)

endif # IS_PYTHON_PROJECT
