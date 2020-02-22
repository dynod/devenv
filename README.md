# A reusable set of development and build tools

This set of tools is essentially based on Makefiles, providing rules to cover
usual needs of software development, build and testing.

It is designed to be fast, incremental, reliable and as simple as possible.

All tasks are handled through **`make`** targets. This allows to have a well
known command line interface, with built-in incremental build and completion
support from scratch, without complex dependencies.

The following pages describe the different features and tasks supported
by this tools set.

## Setup tasks

Tasks are provided to handle different workspace setup tasks (source code
fetching, dependencies resolution, etc...).

See [related page](./doc/setup.md) or **`make help-setup`**
