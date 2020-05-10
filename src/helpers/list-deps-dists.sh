#!/bin/bash

# Invoked with list of dependencies
for DEP in "$@"; do
    # Only is dependency project exists
    if test -e "${DEP}"; then
        # Get Python dependency
        DEP_DIST="$(SUB_MAKE=1 DISPLAY_MAKEFILE_VAR=PYTHON_DISTRIBUTION make -C ${DEP} display | grep -vE '^make')"

        # Add to list only if there is a distribution
        if test -n "${DEP_DIST}"; then
            # Built locally?
            if test -e "${DEP_DIST}"; then
                echo "${DEP_DIST}"
            elif test -n "${PYTHON_INTERNAL_REPOSITORY_URL}"; then
                # Will install from internal repository (with provided URL)
                echo "${PYTHON_INTERNAL_REPOSITORY_URL}/$(basename ${DEP_DIST})"
            fi
        fi
    fi
done
