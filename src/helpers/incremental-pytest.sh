#!/bin/bash
set -e

# Stamp file to retrigger tests in case of failure
STAMP_FILE="$1"
shift

# Test report
TEST_REPORT="$1"
shift

# Remove stamp file to let pytest fail this script in case of failure
rm -f "${STAMP_FILE}"

# Trigger tests
pytest --cov-fail-under=100

# Tests were successful: touch stamp file for incremental behavior
touch "${STAMP_FILE}" "${TEST_REPORT}"
