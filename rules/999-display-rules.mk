# Tweak rule to display a makefile value, used by helpers
ifdef DISPLAY_MAKEFILE_VAR

# Variable values
DISPLAY_VALUES := $(foreach V,$(DISPLAY_MAKEFILE_VAR),$($(V)))

.PHONY: display
display:
	echo $(DISPLAY_VALUES)

endif # DISPLAY_MAKEFILE_VAR
