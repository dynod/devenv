#!/bin/bash
set -e

# First arg is Python command to call to setup the venv
PYTHON_FOR_VENV="$1"
shift

# Second arg is venv location
PYTHON_VENV="$1"
shift

# Remaining args are requirement files
DEPFILES="$@"

# Prepare venv
RC=0
$PYTHON_FOR_VENV -m venv $PYTHON_VENV || RC=$?
if test "$RC" -ne 0; then
    echo "Cleaning corrupted $PYTHON_VENV folder"
    rm -R $PYTHON_VENV;
    exit $RC;
fi

# Finaly finish setup by doing pip installs
PIP_CMD="pip install "
for DEPFILE in $DEPFILES; do
    PIP_CMD="$PIP_CMD -r $DEPFILE"
done
(source $PYTHON_VENV/bin/activate && $PIP_CMD)
touch $PYTHON_VENV
