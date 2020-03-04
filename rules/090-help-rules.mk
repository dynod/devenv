# Just some rules to display help pages

# Default
.PHONY: help
help:
	$(HELP_DISPLAY) $(HELP_URL_ROOT)/README.md

# Help pages
.PHONY: $(HELP_RULES)
$(HELP_RULES):
	$(HELP_DISPLAY) $(HELP_PAGE_FROM_TARGET)
