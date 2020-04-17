# Code generation rules

ifdef IS_CODEGEN_PROJECT
ifdef IS_PYTHON_PROJECT

# Code generation for Python projects
.PHONY: codegen
codegen: $(PYTHON_GEN_FILES)

# Generated files
$(PYTHON_GEN_FOLDER)/%_pb2.py: $(PROTO_FOLDER)/%.proto
	mkdir -p $(PYTHON_GEN_FOLDER)
	$(IN_PYTHON_VENV) $(FILE_STATUS) -t codegen --lang python -s "Generate code from `basename $<`" \
		python3 -m grpc_tools.protoc --proto_path $(PROTO_FOLDER) --python_out $(PYTHON_GEN_FOLDER) --grpc_python_out $(PYTHON_GEN_FOLDER) $<
	$(PYTHON_CODE_FORMAT_CMD) -t codegen `echo $@ | sed -e "s/.py$$//"`*.py

# For package init
$(PYTHON_GEN_INIT):
	mkdir -p $(PYTHON_GEN_FOLDER)
	touch $(PYTHON_GEN_INIT)

endif # IS_PYTHON_PROJECT
endif # IS_CODEGEN_PROJECT
