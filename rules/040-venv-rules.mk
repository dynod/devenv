# Rules for Python virtual env

# Common phony targets
.PHONY: clean-venv

# Only if current project is a Python one
ifdef IS_PYTHON_PROJECT

# Virtual env for current project
# Handle clean of venv folder if something went wrong...
$(PYTHON_VENV): $(PYTHON_VENV_REQUIREMENTS)
	RC=0 && \
	$(PYTHON_FOR_VENV) -m venv $(PYTHON_VENV) || RC=$$? && \
	if test "$$RC" -ne 0; then \
		echo "Cleaning corrupted $(PYTHON_VENV) folder" && \
		rm -R $(PYTHON_VENV); \
		exit $$RC; \
	fi
	# Finaly finish setup by doing pip installs
	(source $(PYTHON_VENV)/bin/activate && pip install $(foreach DEPFILE,$<,-r $(DEPFILE)))
	touch $(PYTHON_VENV)

# Clean virtual env
clean-venv:
	rm -R $(PYTHON_VENV)

else # IS_PYTHON_PROJECT
ifndef PROJECT_ROOT

# At workspace root, trigger venv build for all projects
$(PYTHON_VENV) clean-venv:
	$(REPO) forall -c "pwd && make $@"

endif # !PROJECT_ROOT
endif # IS_PYTHON_PROJECT
