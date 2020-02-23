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
* Verify system dependencies (TBD)
* Prepare development environment (TBD)

Note that the simple **setup** target can be used to re-execute the
setup process for the current project set (except the group selection).

## Project set selection - "init-xxx"

This target handle the necessary **`repo init`** command to initialize the 
workspace with the chosen project set (group)

## Source code synchronization - "sync"

This target handle the necessary **`repo sync`** command to trigger source 
code synchronization.
It also prepare local branch for all projects in the workspace.
