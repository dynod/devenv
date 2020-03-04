# Rules for Python virtual env

# Common phony targets
.PHONY: clean-venv

# Only if current project is a Python one
ifdef IS_PYTHON_PROJECT

ifdef SUB_MAKE
# Triggered at workspace level, don't check system dependencies (already done)
PYTHON_VENV_DEPS := $(PYTHON_VENV_REQUIREMENTS)
else
# Triggered at project level, check system dependencies
PYTHON_VENV_DEPS := $(PYTHON_VENV_REQUIREMENTS) $(SYSDEPS_TIME)
endif

# Virtual env for current project
# Handle clean of venv folder if something went wrong...
$(PYTHON_VENV): $(PYTHON_VENV_DEPS)
	$(GIFT_STATUS) -s "Create Python virtual environment" $(HELPERS_ROOT)/setup-venv.sh $(PYTHON_FOR_VENV) $(PYTHON_VENV) $<

# Clean virtual env
clean-venv:
	$(CLEAN_STATUS) -s "Clean Python virtual environment" rm -Rf $(PYTHON_VENV)

else # IS_PYTHON_PROJECT

# If not in a Python project, venv is phony
.PHONY: $(PYTHON_VENV)

ifndef PROJECT_ROOT

# At workspace root, trigger venv build for all projects
clean-venv:
	$(MULTI_STATUS) -s "Clean all Python virtual environments"
	SUB_MAKE=1 $(REPO) forall -c "make $@"
$(PYTHON_VENV): $(SYSDEPS_TIME)
	$(MULTI_STATUS) -s "Create all Python virtual environments"
	SUB_MAKE=1 $(REPO) forall -c "make $@"

else # !PROJECT_ROOT

# In a non-Python project, just stub venv targets
$(PYTHON_VENV) clean-venv: stub

endif # !PROJECT_ROOT
endif # IS_PYTHON_PROJECT
