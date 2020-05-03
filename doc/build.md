# Build tasks

This tools set defines **`make`** targets to handle build tasks for different supported languages,
described in the following chapters.

## Docker

**`docker-image`** target is provided to build Docker image present in a Docker project.

The target is incremental and rebuild the image only when the associated Dockerfile changes.

## Clean

The build system provides the following targets to clean part or all of the generated files:
- **`clean`** target will erase all generated files and folders
- **`clean-out`** target will erase only the output directory (**OUTPUT_ROOT** variable)
- **`clean-venv`** target will erase only the Python virtual environment folder, if applicable (**PYTHON_VENV** variable)

Note that these targets are recursive when used at workspace root.
