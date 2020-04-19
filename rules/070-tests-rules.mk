# Rules to handle the test target

# Python project?
ifdef IS_PYTHON_PROJECT

# Somthing to test?
ifdef TEST_REPORT

# Add test target
.PHONY: tests
tests: build $(TEST_REPORT)

# Real tests run
$(TEST_REPORT): $(PYTHON_VENV) $(PYTHON_SETUP) $(TEST_FILES) $(TEST_TIME)
	rm -Rf $(TEST_ROOT)
	$(CROSS_FINGER_STATUS) -t pytest --lang python -s "Running Python tests"
	$(IN_PYTHON_VENV) $(HELPERS_ROOT)/incremental-pytest.sh $(TEST_TIME) $(TEST_REPORT)

# Is it a package?
ifdef PYTHON_DISTRIBUTION_INSTALL
# Depend on local install
$(TEST_REPORT): $(PYTHON_DISTRIBUTION_INSTALL)
else
# Simply depend on source files
$(TEST_REPORT): $(SRC_FILES)
endif

# Default rule to rebuild test stamp file
$(TEST_TIME):
	touch $(TEST_TIME)

endif # TEST_REPORT

endif # IS_PYTHON_PROJECT
