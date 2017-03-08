# Mason

This repository contains a Bash client for [Mason packages](https://github.com/mapbox/mason). It can **only download libraries and extract compiler flags** from the archives, and does *not handle building* packages.

### Usage

Copy the `mason.sh` file into your project. It is the only dependency.

To install packages, use `./mason.sh install <package> <version>`. In fact, you can replace `install` with any string you want; Mason will always download and unpack the package. If the `mason.ini` file contains a variable with that name, it'll print it. So instead of first calling `install` and then querying compiler flags flags from that package, you can directly query flags.

Since the Bash client does not read any script files prior to downloading packages, you'll need to tell it that you want a **header only package** by using the `--header-only` flag anywhere after the initial verb, e.g. `./mason.sh prefix --header-only geometry 0.9.0`.

### Querying flags

Use `./mason.sh <flag> <package> <version>` to print out flags from the `mason.ini` file. The value of `flag` is case insensitive. These are the flags that the Mason build system produces:

* `prefix`: Absolute path to the package
* `include_dirs`: List of absolute paths to include directories
* `static_libs`: List of absolute paths to static libraries in this package
* `ldflags`: Linker flags required when linking this library
* `definitions`: Key-value pairs of define flags (without `-D`)
* `options`: Compiler flags (without include directories and defines)

Note that these flags don't necessarily exist in every `mason.ini`; if they they don't exist, Mason will not print anything, and will return an exit code of 0 (no failure).

### Querying many flags

Instead of using separate bbash invocations to obtain flags, you can also `source mason.sh` in your build system, and add `mason_use <package> <version>` calls to install dependencies. Similarly to the standalone interface, you can also pass `--header-only` to install header-only packages.

After a successful installation, all key-value pairs from the package's `mason.ini` will be defined as variables in the environment with the following pattern: `MASON_PACKAGE_<package>_<KEY>`, with `<package>` being the package name you used when running `mason_use`, and `<KEY>` the uppercase property (one of `PREFIX`, `INCLUDE_DIRS`, `STATIC_LIBS`, etc.). When querying variables, make sure you use `${MASON_PACKAGE_<package>_<KEY>:-}` to avoid errors for undefined variables.
