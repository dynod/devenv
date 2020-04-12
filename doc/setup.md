# Setup tasks

This tools set defines **`make`** targets to handle different setup tasks,
described in the following chapters.

## Project sets

The workspace may be split in several project sets. This is supported by the
**`repo`** tool *groups* feature (using the **-g** option or **`repo init`**).

Some of the following targets are working with a given project set (e.g. 
**setup-xxx** targets). In that case, the target suffix represents the project
set name. Please use the make completion to know the list of available project
sets for the current workspace, and/or refer to the workspace documentation.

## All in one setup - "setup-xxx"

This target handles the complete setup of the selected project set (**xxx**).
It is a global target that successively handles the following steps:
* Select the project set (see **init-xxx**)
* Synchronize the source code (see **sync**)
* Verify system dependencies (see **sysdeps**)
* Prepare development environment (see **venv**)

Note that the simple **setup** target can be used to re-execute the
setup process for the current project set (except the group selection).

## Project set selection - "init-xxx"

This target handle the necessary **`repo init`** command to initialize the 
workspace with the chosen project set (group)

Additionally, if some specific branches are requested to be checked out instead of
the master one, the **MANIFEST_BRANCHES** variable can be set. It has to be a space
separated list of *name/branch* couples, where:
* **name** is the project name (as referenced in the master manifest)
* **branch** is the branch to be checked out for that project

Note that once switched in branch mode, any further **`make setup-xxx`** or **`make init-xxx`** will stick 
to the switched branch. To get back to the original master manifest, just set the **MANIFEST_RESET** variable.

## Source code synchronization - "sync"

This target handle the necessary **`repo sync`** command to trigger source 
code synchronization.
It also prepare local branch for all projects in the workspace:
* either the **master** one if default manifest is used
* or specific ones if the **MANIFEST_BRANCHES** is set (see above)

## Prepare development environment

According to the kind of project and to the desired features, several tasks
are available for development environment setup.

### Development environment settings

Each project can define its own development environment settings.
These settings are stored in the **.devenv** folder under the project root.

### Verify system dependencies - "sysdeps"

This target verifies that all necessary system dependencies are installed, so
that other tasks can be handled properly.

Each project can declare its dependencies in simple **txt** files in their
**system** settings folder.

Each file in these **txt** files is a requirement to be verified; it can be:
* either an absolute path; the requirement is considered as missing if this path
  doesn't exist
* or a simple *command*; the requirement is considered as missing if a
  **`which`** *`command`* call fails

If there is at least a missing requirement, an install process is triggered.
System packages to be installed for each requirement are resolved by parsing
"database" files named **sysdeps.json** in **system** settings folders.

These json files syntax is:
```json
{
    "requirement": {
        "apt": "package"
    }
}
```
Where:
* `requirement`: the requirement to be resolved (the same than in **txt** files)
* `apt`: package manager (only **apt** is supported at the moment)
* `package`: name of the package to be installed
See [example database file](../.devenv/system/sysdeps.json)

System dependencies verification is incremental and only verified:
* on first setup
* if requirements or "database" files are modified
* if packages have been modified on the system

The process behavior can be modified by setting the following variables:
* **`SYSDEPS_REINSTALL`**: bypass requirements verification and incremental
  behavior, and reinstall all packages
* **`SYSDEPS_YES`**: don't prompt before installing packages

### Python projects virtual environment - "venv"

Python projects are identified by providing a **python** folder in their
settings folder. The following setup targets are available for python projects.

Python virtual environment can be setup by using the **venv** target.
By the way, this target is also part of the all in one **setup**.

The virtual environment is built from a list of requirements, automatically
gathered from all **.txt** files in the **python** settings folder of current
project.
Note that any project can provide shared requirements in their **python/shared**
settings folder. These requirements will be installed in all projects of the 
workspace

The Python executable used to setup the virtual environment is configured in 
the **`PYTHON_FOR_VENV`** variable (default value is *python3*). It can be 
configured to something else by any project.
