# Just some rules to display help pages

# Default
.PHONY: help
help:
	$(PAGER) $(TOOLS_ROOT)/README.md

# Help pages
.PHONY: $(HELP_RULES)
$(HELP_RULES):
	$(PAGER) $(HELP_PAGE_FROM_TARGET)
