# Tests tasks

This tools set defines **`make`** targets to handle tests tasks for different supported languages,
described in the following chapters.

## Python tests

### Static code analysis - "flake8"

The **flake8** target will trigger Python source code (from both source and test folders) using the **`flake8`** tool.

Report is generated in **out/flake-report** folder. This can be changed by overriding the **FLAKE_ROOT** variable.

*Note:* this target is automatically invoked as dependency of the **tests** targets.

### Python tests - "tests"

The **tests** target will trigger Python tests using the **`pytest`** tool.

Tests files are expected to be found in the **src/tests** folder. This can changed by overriding the **TEST_FOLDER** variable.

Tests execution is performed in multi-process mode, using by default all the current host cores. Tests must be designed to be multi-process compatibles.

The **test** execution will be considered as a failure if:
* at least one test if failed
* tested code coverage doesn't reach 100%
