# Build tasks

This tools set defines **`make`** targets to handle build tasks for different supported languages,
described in the following chapters.

## Docker

**`docker-images`** target is provided to build all Docker images present in a Docker project.

The target is incremental and rebuild the image only when the associated Dockerfile changes.
