# Rules for Python virtual env

# Common phony targets
.PHONY: clean-venv

# Only if current project is a Python one
ifdef IS_PYTHON_PROJECT

# Virtual env for current project
# Handle clean of venv folder if something went wrong...
$(PYTHON_VENV): $(PYTHON_VENV_DEPS)
	export PYTHON_VENV_EXTRA_ARGS="$(PYTHON_VENV_EXTRA_ARGS)" && \
	$(GIFT_STATUS) --lang python -s "Update Python virtual environment" -- $(HELPERS_ROOT)/setup-venv.sh \
		$(PYTHON_FOR_VENV) \
		$(PYTHON_VENV) \
		$(PYTHON_VENV_REQUIREMENTS) \
		$(PYTHON_VENV_WORKSPACE_REQUIREMENTS)

# Clean virtual env
clean-venv:
	$(CLEAN_STATUS) --lang python -s "Clean Python virtual environment" -- rm -Rf $(PYTHON_VENV)

else # IS_PYTHON_PROJECT

# If not in a Python project, venv is phony
.PHONY: $(PYTHON_VENV)

ifndef PROJECT_ROOT
ifdef CI_PROJECT_ROOT
# At workspace root, trigger venv build only in CI_PROJECT_ROOT
BUILD_CI_VENV = 1
endif # !CI_PROJECT
endif # !PROJECT_ROOT

ifdef BUILD_CI_VENV

clean-venv:
	$(MULTI_STATUS) -s "Clean Python virtual environment for CI built project ($(CI_PROJECT))"
	SUB_MAKE=1 make -C $(CI_PROJECT_ROOT) $@
$(PYTHON_VENV): $(SYSDEPS_TIME)
	$(MULTI_STATUS) -s "Update Python virtual environment for CI built project ($(CI_PROJECT))"
	SUB_MAKE=1 make -C $(CI_PROJECT_ROOT) $@

else # BUILD_CI_VENV

# Other cases (non-Python project, or at workspace root but not in CI)
$(PYTHON_VENV) clean-venv: stub

endif # BUILD_CI_VENV

endif # IS_PYTHON_PROJECT
