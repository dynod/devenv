#!/bin/bash
set -e

# First arg is Python command to call to setup the venv
PYTHON_FOR_VENV="$1"
shift

# Second arg is venv location
PYTHON_VENV="$1"
shift

# Remaining args are either requirement files (.txt) or archive files coming from dependencies
REQS_LIST=""
DIST_LIST=""
for CANDIDATE in "$@"; do
    if test "$(basename ${CANDIDATE})" !=  "$(basename -s txt ${CANDIDATE})"; then
        REQS_LIST="${REQS_LIST} ${CANDIDATE}"
    else
        DIST_LIST="${DIST_LIST} ${CANDIDATE}"
    fi
done

# Prepare venv
RC=0
$PYTHON_FOR_VENV -m venv $PYTHON_VENV || RC=$?
if test "$RC" -ne 0; then
    echo "Cleaning corrupted $PYTHON_VENV folder"
    rm -R $PYTHON_VENV;
    exit $RC;
fi

# Install dependencies first, if any, and if file exist
PIP_CMD="pip install --upgrade --force-reinstall"
if test -n "${DIST_LIST}"; then
    for DIST in $DIST_LIST; do
        PIP_CMD="$PIP_CMD ${DIST}"
    done
    (source $PYTHON_VENV/bin/activate && $PIP_CMD)
fi

# Finaly finish setup by doing pip installs
PIP_CMD="pip install"
for DEPFILE in $REQS_LIST; do
    PIP_CMD="$PIP_CMD -r $DEPFILE"
done
(source $PYTHON_VENV/bin/activate && $PIP_CMD)
touch $PYTHON_VENV
