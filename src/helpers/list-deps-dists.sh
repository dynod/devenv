#!/bin/bash

# Invoked with list of dependencies
for DEP in "$@"; do
    # Only is dependency project exists
    if test -e "${DEP}"; then
        # Get Python dependency
        DEP_DIST="$(SUB_MAKE=1 DISPLAY_MAKEFILE_VAR=PYTHON_DISTRIBUTION make -C ${DEP} display | grep -vE '^make')"

        # Add to list only if there is a built distribution
        if test -n "${DEP_DIST}" -a -e "${DEP_DIST}"; then
            echo "${DEP_DIST}"
        fi
    fi
done
