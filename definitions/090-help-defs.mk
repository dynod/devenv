# Some definitions for help pages

# Help pages
HELP_ROOT := $(TOOLS_ROOT)/doc
HELP_PAGES := $(wildcard $(HELP_ROOT)/*.md)

# URL root
HELP_URL_ROOT := https://github.com/stuffnodes/tools/blob/master
HELP_DISPLAY := xdg-open

# Help rules list + some tweak
HELP_RULES := $(foreach PAGE,$(HELP_PAGES),help-$(shell basename -s .md $(PAGE)))
HELP_PAGE_FROM_TARGET = $(HELP_URL_ROOT)/doc/$(subst help-,,$@).md
