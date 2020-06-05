#!/bin/bash
set -e

# Build version from SCM
GIT_VERSION="$(git describe --tags 2>/dev/null || true)"
if test -z "${GIT_VERSION}"; then
    # Probably no tags, build from 0
    GIT_VERSION="0.0.0-$(git rev-list --count $(git rev-parse --abbrev-ref HEAD))-g$(git describe --always)"
fi
echo "${GIT_VERSION}"
