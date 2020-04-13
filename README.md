# A reusable set of development and build tools

![Tests](https://github.com/dynod/devenv/workflows/Tests/badge.svg)

This set of tools is essentially based on Makefiles, providing rules to cover
usual needs of software development, build and testing.

It is designed to be fast, incremental, reliable and as simple as possible.

All tasks are handled through **`make`** targets. This allows to have a well
known command line interface, with built-in incremental build and completion
support from scratch, without complex dependencies.

The following pages describe the different features and tasks supported
by this tools set.

## Setup

Make targets are provided to handle different workspace setup tasks (source code
fetching, dependencies resolution, etc...).

See [related page](./doc/setup.md) or **`make help-setup`**

## Builds

Make targets are provided to handle build tasks.

See [related page](./doc/build.md) or **`make help-build`**

## Tests

Software tests are also handled through make targets.

See [related page](./doc/tests.md) or **`make help-tests`**

## Miscellaneous

Finally, some variables are provided to tune the targets behavior.

See [related page](./doc/misc.md) or **`make help-misc`**
