# Code generation rules

ifdef IS_CODEGEN_PROJECT
ifdef IS_PYTHON_PROJECT

# Code generation for Python projects
.PHONY: codegen
codegen: $(PYTHON_GEN_FILES)

# Generated files
$(PYTHON_GEN_FOLDER)/%_pb2.py: $(PROTO_FOLDER)/$(PROTO_PACKAGE)/%.proto
	mkdir -p $(PYTHON_GEN_FOLDER)
	$(IN_PYTHON_VENV) $(FILE_STATUS) -t codegen --lang python -s "Generate code from `basename $<`" -- \
		python3 -m grpc_tools.protoc --proto_path $(PROTO_FOLDER) --python_out $(SRC_FOLDER) --grpc_python_out $(SRC_FOLDER) $<

# For package init
$(PYTHON_GEN_INIT):
	mkdir -p $(PYTHON_GEN_FOLDER)
	echo "# Public generated API" > $(PYTHON_GEN_INIT)
	for package in $(PYTHON_GEN_PACKAGES); do echo "from $$package import * # NOQA: F401,F403" >> $(PYTHON_GEN_INIT); done

endif # IS_PYTHON_PROJECT
endif # IS_CODEGEN_PROJECT
