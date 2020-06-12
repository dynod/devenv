#!/bin/sh
set -e
set -u

__usage () {
	echo "Usage: $0 <TARGET_FOLDER> <NAME> <VERSION> <DESCR> <SKEL_FOLDER> <RES_FOLDER> <DIST_FILE> ..."
	echo "TARGET_FOLDER: where deb will be generated"
	echo "NAME: name of the Debian package"
	echo "VERSION: version of the Debian package"
	echo "DESCR: description of the deb package to be built"
	echo "SKEL_FOLDER: path to the debian structure skeleton folder for this package"
	echo "             (other skeleton files will be got from DEB_DEVENV_SKEL and DEB_WORKSPACE_SKEL folders)"
	echo "RES_FOLDER: path to the resource files to be bundled in this package"
	echo "DIST_FILE: list of distribution files/folders to be bundled"
}

if test $# -lt 7; then
	__usage
	exit 1
fi

# Reading parameters
TARGET_FOLDER="$1"
shift
NAME="$1"
shift
VERSION="$1"
shift
DESCR="$1"
shift
SKEL_FOLDER="$1"
shift
RES_FOLDER="$1"
shift
DIST_FILES="$@"
echo "Target folder: $TARGET_FOLDER"
echo "Name: $NAME"
echo "Version: $VERSION"
echo "Description: $DESCR"
echo "Skel folder: $SKEL_FOLDER"
echo "Resources folder: $RES_FOLDER"
echo "Using dist files: $DIST_FILES"

ROOT_FOLDER=$(dirname "$0")/$NAME
COMMON_FOLDER=$(dirname "$0")/common
mkdir -p "$TARGET_FOLDER"

# Prepare folders for copy
WORKING_FOLDER="$TARGET_FOLDER/extracted"
rm -rf "$WORKING_FOLDER"
mkdir -p "$WORKING_FOLDER/dist"

# Skel files from devenv (default shared ones)
cp -a "$DEB_DEVENV_SKEL"/* "$WORKING_FOLDER/"

# Skel files from workspace (other shared ones)
if test -n "${DEB_WORKSPACE_SKEL}"; then
	cp -a "$DEB_WORKSPACE_SKEL"/* "$WORKING_FOLDER/"
fi

# Skel files from project
cp -a "$SKEL_FOLDER"/* "$WORKING_FOLDER/"

# Dist and resource files
cp -a $DIST_FILES "$WORKING_FOLDER/dist"
cp -a "$RES_FOLDER"/* "$WORKING_FOLDER/"

# Copy debian skel and update templates
find "$WORKING_FOLDER/" -type f -exec sed -i {} -e "s/{NAME}/$NAME/g;s/{VERSION}/$VERSION/g" \;

# Create deb
(
	cd "$WORKING_FOLDER" \
	&& dch --create --package "$NAME" --newversion "$VERSION" -u low -D release --force-distribution -M "$DESCR" \
	&& debuild -b
)
