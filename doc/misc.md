# Miscellaneous parameters

Following variables can be set to tune the build behavior.

## BUILD_LOGS

By default, build logs are saved in **/tmp/build-logs**. This location can be changed
by setting the **`BUILD_LOGS`** variable.

## STATUS_NO_CLEAN

By default, build logs are cleaned on every call.
If the **`STATUS_NO_CLEAN`** variable is set, they won't be cleaned.

## STATUS_VERBOSE

By default, performed operations output is just persisted in build logs, and only a status line is displayed.
If the **`STATUS_VERBOSE`** variable is set, output will be directly displayed.
