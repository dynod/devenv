# Some definitions for help pages

# Help pages
HELP_ROOT := $(TOOLS_ROOT)/doc
HELP_PAGES := $(wildcard $(HELP_ROOT)/*.md)

# Help rules list + some tweak
HELP_RULES := $(foreach PAGE,$(HELP_PAGES),help-$(shell basename -s .md $(PAGE)))
HELP_PAGE_FROM_TARGET = $(HELP_ROOT)/$(subst help-,,$@).md

# Paging
PAGER ?= less
