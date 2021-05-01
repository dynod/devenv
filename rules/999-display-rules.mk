# Tweak rule to display a makefile value, used by helpers
ifdef DISPLAY_MAKEFILE_VAR

# Variable values
ifdef WITH_VALUE_SEPARATORS
DISPLAY_VALUES := $(foreach V,$(DISPLAY_MAKEFILE_VAR),@<@$($(V))@>@)
else
DISPLAY_VALUES := $(foreach V,$(DISPLAY_MAKEFILE_VAR),$($(V)))
endif

.PHONY: display
display:
	echo "$(DISPLAY_VALUES)"

endif # DISPLAY_MAKEFILE_VAR
