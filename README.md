# Mason

Mason is a cross-platform, command-line package manager for C/C++ applications.

Mason is like:

* [npm](https://github.com/npm/npm) because it installs packages in the current working directory (`./mason_packages`) rather than globally (and therefore does not require privileges for, or conflict with, system-wide packages)
* [homebrew](http://brew.sh/) because it requires no use of `sudo` to install packages
* [apt-get](https://linux.die.net/man/8/apt-get) or [yum](https://linux.die.net/man/8/yum) because it works on Linux

Mason is unlike:

 * all of the above...

    Mason is a collection of bash scripts and does not depend on any specific runtime language, such as python, node.js, or ruby. It can build and publish a single set of binaries (>= OS X 10.8 and >= Ubuntu Precise), publish header-only files, and install packages. Mason has integrations with [Travis CI](https://travis-ci.org) and [Amazon S3](https://aws.amazon.com/s3) for automated build and deployment.

    Mason strongly prefers static libraries over shared libraries and has zero understanding of dependency trees: it leaves complete control to the developer for how packages relate.

Mason works on both **OS X** and **Linux**.

[![Build Status](https://travis-ci.org/mapbox/mason.svg?branch=master)](https://travis-ci.org/mapbox/mason)

# Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Creating a package](#creating-a-package)
    - [Prerequisites](#prerequisites)
    - [Getting started](#getting-started)
    - [System packages](#system-packages)
- [Releasing a package](#releasing-a-package)
- [Using a package](#using-a-package)
- [Mason internals](#mason-internals)
    - [Mason scripts](#mason-scripts)
    - [Mason variables](#mason-variables)
    - [Mason functions](#mason-functions)
- [Troubleshooting](#troubleshooting)

## Installation

There are three recommended ways to install mason, via:

* [Curl](#curl)
* [Submodule](#submodule)
* [mason.cmake](#masoncmake)

#### Curl

To install mason locally:

```sh
mkdir ./mason
curl -sSfL https://github.com/mapbox/mason/archive/v0.18.0.tar.gz | tar --gunzip --extract --strip-components=1 --exclude="*md" --exclude="test*" --directory=./mason
```

Then you can use the `mason` command like: `./mason/mason install <package> <version>`

To install mason globally (to /tmp):

```sh
curl -sSfL https://github.com/mapbox/mason/archive/v0.18.0.tar.gz | tar --gunzip --extract --strip-components=1 --exclude="*md" --exclude="test*" --directory=/tmp
```

Then you can use the `mason` command like: `/tmp/mason install <package> <version>`

#### Submodule

Mason can also be added as a submodule to your repository. This is helpful for other contributors to get set up quickly.

Optionally a convention when using submodules, is to place the submodule at a path starting with `.` to make the directory hidden to most file browsers. If you want your mason folder hidden then make sure to include the final part of the following command `.mason/` so your submodule path has the leading `.` instead of just being `mason/`.

```bash
git submodule add git@github.com:mapbox/mason.git .mason/
```

This will append a few lines to your `.gitmodules` file. Make sure to change the `url` parameter to `https` instead of `git@github` ssh protocol.

```
[submodule ".mason"]
    path = .mason
    url = https://github.com/mapbox/mason.git
```

Update your `Makefile` to point to the mason scripts and provide an installation script for the necessary dependencies. The following installs two Mason packages with the `make mason_packages` command.

```Make
MASON ?= .mason/mason

$(MASON):
    git submodule update --init

mason_packages: $(MASON)
    $(MASON) install geometry 0.7.0
    $(MASON) install variant 1.1.0
```

#### mason.cmake

Copy the https://raw.githubusercontent.com/mapbox/mason/master/mason.cmake into your cmake project. A common convention is to place it at `<your project>/cmake/mason`

```
mkdir cmake
wget -O cmake/mason.cmake https://raw.githubusercontent.com/mapbox/mason/master/mason.cmake
````

Then in your `CmakeLists.txt` install packages like:

```cmake
mason_use(<package name> VERSION <package version> HEADER_ONLY)
```

_Note: Leave out `HEADER_ONLY` if the package is a [precompiled library](https://github.com/mapbox/cpp/blob/master/glossary.md#precompiled-library). You can see if a package is `HEADER_ONLY` by looking inside the `script.sh` for `MASON_HEADER_ONLY=true` like https://github.com/mapbox/mason/blob/68871660b74023234fa96d482898c820a55bd4bf/scripts/geometry/0.9.0/script.sh#L5_

## Configuration

By default Mason publishes packages to a Mapbox-managed S3 bucket. If you want to publish to a different bucket we recommend taking the following steps:

1. Fork Mason and rename it to `mason-{your_org}`
2. Set [`MASON_BUCKET`](https://github.com/mapbox/mason/blob/2765e4ab50ca2c1865048e8403ef28b696228f7b/mason.sh#L6) to your own S3 bucket
3. Publish packages to the new location

## Usage

Most commands are structured like this:

```bash
mason <command> <library> <version>
```

The `command` can be one of the following

* [install](#install) - installs the specified library/version
* [remove](#remove) - removes the specified library/version
* [build](#build) - forces a build from source (= skip pre-built binary detection)
* [publish](#publish) - uploads packages to the S3 bucket
* [prefix](#prefix) - prints the absolute path to the library installation directory
* [version](#version) - prints the actual version of the library (only useful when version is `system`)
* [cflags](#cflags) - prints C/C++ compiler flags
* [ldflags](#ldflags) - prints linker flags
* [link](#link) - creates symlinks for packages in `mason_packages/.link`
* [trigger](#trigger) - trigger a build and publish operation on Travis CI

#### install

```bash
$ mason install libuv 0.11.29
* Downloading binary package osx-10.10/libuv/0.11.29.tar.gz...
######################################################################## 100.0%
* Installed binary package at /Users/user/mason_packages/osx-10.10/libuv/0.11.29
```

Installs [libuv](https://github.com/joyent/libuv) into the current folder in the `mason_packages` directory. Libraries are versioned by platform and version number, so you can install several different versions of the same library along each other. Similarly, you can also install libraries for different platforms alongside each other, for example library binaries for OS X and iOS.

The `install` command first checks if the specified library/version is already present for this platform, and if so, exits. This means you can run it multiple times (e.g. as part of a configuration script) without doing unnecessary work.

Next, Mason checks whether there are pre-built binaries available in the S3 bucket for the current platform. If that is the case, they are downloaded and unzipped and the installation is complete.

If no pre-built binaries are available, Mason is going to build the library according to the script in the `mason_packages/.build` folder, and install into the platform- and library-specific directory.

#### remove

```bash
$ mason remove libuv 0.11.29
* Removing existing package...
/Users/user/mason_packages/osx-10.10/libuv/0.11.29/include/uv-darwin.h
[...]
/Users/user/mason_packages/osx-10.10/libuv/0.11.29
```

Removes the specified library/version from the package directory.

#### build

This command works like the `install` command, except that it *doesn't* check for existing library installations, and that it *doesn't* check for pre-built binaries, i.e. it first removes the current installation and *always* builds the library from source. This is useful when you are working on a build script and want to fresh builds.

#### publish

Creates a gzipped tarball of the specified platform/library/version and uploads it to the `mason-binaries` S3 bucket. If you want to use this feature, you need write access to the bucket and need to specify the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

#### prefix

```bash
~ $ mason prefix libuv 0.11.29
/Users/user/mason_packages/osx-10.10/libuv/0.11.29
```

This prints the absolute path to the installation directory of the the library/version. Likely, this folder has the typical `include` and `lib` folders.

#### version

```bash
~ $ mason version zlib system
1.2.11
```

This prints the version of the library, which is only useful when version is `system`. See [System packages](#system-packages) for more details.

#### cflags

```bash
~ $ mason cflags libuv 0.11.29
-I/Users/user/mason_packages/osx-10.10/libuv/0.11.29/include
```

Prints the C/C++ compiler flags that are required to compile source code with this library. Likely, this is just the include path, but may also contain other flags.

#### ldflags

```bash
~ $ mason ldflags libuv 0.11.29
-L/Users/user/mason_packages/osx-10.10/libuv/0.11.29/lib -luv -lpthread -ldl
```

Prints the linker flags that are required to link against this library.

#### link

```bash
~ $ mason link libuv 0.11.29
```

This command only works if the package has already been installed. When run it symlinks the versioned `lib`, `include`, `share`, and `bin` folders of the package into a shared structure that is unversioned. For example if `mason prefix libuv 0.11.29` was `./mason_packages/osx-10.10/libuv/0.11.29` then the library would become available at `./mason_packages/.link/lib/libuv.a`

#### trigger

In order to ensure that all pre-built binaries are consistent and reproducible, we perform the final build and publish operation on Travis CI.

First set the `MASON_TRAVIS_TOKEN` environment variable. You can do this either by installing the `travis` gem and running `travis token` or by using `curl` to hit the Travis api directly. See details on this below. **WARNING: be careful to keep this token safe. Cycling it requires emailing support@travis-ci.com. Giving someone an access token is like giving them full access to your Travis account.**

Once you are set up with your `MASON_TRAVIS_TOKEN` then use the `trigger` command to kick off a build:

```bash
./mason trigger <package name> <package version>
```

Run this command from the root of a local mason repository checkout. It makes a request to the Travis API to build and publish the specified version of the package, using the Travis configuration in `./scripts/${MASON_NAME}/${MASON_VERSION}/.travis.yml`.

1) Using curl and travis api to generate MASON_TRAVIS_TOKEN

First generate a github personal access token that has `repo` scope by going to https://github.com/settings/tokens. More details at https://help.github.com/articles/creating-an-access-token-for-command-line-use/.

Then set that in your environment and run:

```sh
GITHUB_TOKEN=<github token>

curl -s -i https://api.travis-ci.org/auth/github \
    -H "User-Agent: Travis/1.0" \
    -H "Content-Type: application/json" \
    -H "Accept: application/vnd.travis-ci.2+json" \
    -H "Host: api.travis-ci.org" \
    -d "{\"github_token\": \"${GITHUB_TOKEN}\"}"
```

2) Use the travis command

For details see https://docs.travis-ci.com/user/triggering-builds and https://github.com/travis-ci/travis.rb#readme

## Creating a package

### Prerequisites

Before getting started you should be able to answer the following questions.

**What are you packaging?**

There are different steps that you will need to follow depending on the type of library you are packaging. For example, there are fewer steps you need to take if you are creating a package of header-only code. Packaging compiled code has more steps because you'll need to tell Mason how to build your binaries. Another type of package is a [System package](#system-package) which has a unique process as well.

**Are there previous versions already published?**

Check the [list of packages](https://github.com/mapbox/mason/tree/master/scripts) to see if a previous version of your package exists. It's helpful to copy scripts from a previous version rather than creating code from scratch.

**Where can Mason download your code?**

Every package needs to tell Mason where to download the code that it will build and publish, for example:

 - `https://github.com/mapbox/geometry.hpp/archive/v0.9.2.tar.gz` for a Github release: [geometry 0.9.2](https://github.com/mapbox/geometry.hpp/releases/tag/v0.9.2)
 - `https://github.com/mapbox/geometry.hpp/archive/b0e41cc5635ff8d50e7e1edb73cadf1d2a7ddc83.zip` for pre-release code hosted on Github: [geometry b0e41cc](https://github.com/mapbox/geometry.hpp/tree/b0e41cc5635ff8d50e7e1edb73cadf1d2a7ddc83)

_Note: Your code doesn't need to be hosted on Github in order for Mason to work. Your code can be hosted anywhere. Another common location is [SourceForge](#https://sourceforge.net/)._

### Getting started

These are just basic steps to help get you started. Depending on the complexity of building your code, you might have to review the [Mason scripts](#mason-scripts) section to get a better idea of how to further configure Mason to be able to create your package.

1. Create a new directory for your package.

    From inside your `mason` checkout, create a directory named `${package}/${version}`. For example, if you have a library named `your-lib` that is version `0.1.0` you would:

    ```bash
    mkdir -p scripts/your-lib/0.1.0
    ```

2. Add scripts for building and publishing your package.

    Each package must have the following two files: `script.sh` and `.travis.yml`. Copy these two files from a previous version of your package.

    If no previous version of your package exists, it is recommended to copy a simple package that has mostly boiler plate code:

     - [geometry](https://github.com/mapbox/mason/tree/master/scripts/geometry/0.9.2) for header-only code
     - [libpng](https://github.com/mapbox/mason/tree/master/scripts/libpng/1.6.32) for building and packaging binaries

    For example, if you're creating the first package of a library named `your-lib` that is version `0.1.0` you would copy scripts from the `geometry` package:

    ```bash
    cp -r scripts/geometry/0.9.1 scripts/your-lib/0.1.0
    ```

3. Edit Mason variables in `script.sh`.

    You **must** set the follow Mason variables:

    - `MASON_NAME`: set to the name of your package, e.g. `your-lib`
    - `MASON_VERSION`: set to the package version, e.g. `0.1.0`
    - `MASON_BUILD_PATH`: set to the location Mason will use to store header files or binaries before it packages and publishes them

    You **may** also need to set the follow Mason variables:

    - Other [Mason variables](#mason-variables)

4. Override Mason functions in `script.sh`.

    You **must** override the follow Mason functions:

    - `mason_load_source`: you must call `mason_download` and update its parameters:
        - url (first parameter): set to the location of your source code archive, e.g. `https://github.com/mapbox/your-lib/archive/v${MASON_VERSION}.tar.gz`
        - gitsha (second parameter): set to the gitsha of the archive tag, which you can retrieve using git's `ls-remote` command, e.g. `git ls-remote --tags https://github.com/mapbox/your-lib` (copy the gitsha corresponding to the version of your archive)
    - `mason_compile`
        - for header-only see [geometry 0.9.2](https://github.com/mapbox/mason/blob/a7e35b0f632a8b2f0e338acc9dda0cff04d2f752/scripts/geometry/0.9.2/script.sh#L19) for an example
        - for code that needs to be compiled see [zlib 1.2.8](https://github.com/mapbox/mason/blob/a7e35b0f632a8b2f0e338acc9dda0cff04d2f752/scripts/zlib/1.2.8/script.sh#L20) for an example

    You **may** also need to override the follow Mason functions:

    - Other [Mason functions](#mason-functions)

### System packages

Some packages ship with operating systems or can be easily installed with operating-specific package managers. For example, `libpng` is available on most systems and the version you're using doesn't really matter since it is mature and hasn't added any significant new APIs in recent years.

The following `script.sh` contains the script code for packaging your system's `libpng`. _Note: To understande this code, make sure to review the [Mason scripts](#mason-scripts) section._

```bash
#!/usr/bin/env bash

MASON_NAME=libpng
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true

. ${MASON_DIR}/mason.sh

if [ ! $(pkg-config libpng --exists; echo $?) = 0 ]; then
    mason_error "Cannot find libpng with pkg-config"
    exit 1
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <png.h>
#include <stdio.h>
#include <assert.h>
int main() {
    assert(PNG_LIBPNG_VER == png_access_version_number());
    printf(\"%s\", PNG_LIBPNG_VER_STRING);
    return 0;
}
" > version.c && ${CC:-cc} version.c $(mason_cflags) $(mason_ldflags) -o version
    fi
    ./version
}

function mason_compile {
    :
}

function mason_cflags {
    pkg-config libpng --cflags
}

function mason_ldflags {
    pkg-config libpng --libs
}

mason_run "$@"
```

System packages are marked with `MASON_SYSTEM_PACKAGE=true`. We're also first using `pkg-config` to check whether the library is present at all. The `mason_system_version` function creates a small executable which outputs the actual version. It is the only thing that is cached in the installation directory.

We have to override the `mason_cflags` and `mason_ldflags` commands since the regular commands return flags for static libraries, but in the case of system packages, we want to dynamically link against the package.

## Releasing a package

Here is an example workflow to help get you started:

1. Create an annotated tag in git for the code you want to package.

    Annotated tags can be stored, checksummed, signed and verified with GNU Privacy Guard (GPG) in Github. To create an annotated tag specify `-a` when running the `tag` command, for example:

    `git tag -a v0.1.0 -m "version 0.1.0"`

2. Share your new tag.

    You have to explicitly push your new tag to a shared Github server. This is the location we will share with Mason when specifying where to download the code to be packaged. Using our example above we would run:

    `git push origin v0.1.0`

    (Or you can push all tags: `git push --tags`.)

3. Create a package.

    We recommend working in a new branch before creating a package. For example if you want to call your new package `my_new_package` version `0.1.0` you could create and checkout a branch like this:

    `git checkout -b my_new_package-0.1.0`

    Now follow the instructions in the [Getting started](#getting-started) section for creating a new package.

4. Test your package.

    Even though we will eventually build the package using Travis, it's a good idea to build locally to check for errors.

     `./mason build my_new_package 0.1.0`

5. Push changes to remote.

    Once you can build, push your changes up to Github remote so that Travis will know what to build and publish in the next step.

    `git push origin my_new_package-0.1.0`

6. Build and Publish your package.

    Use Mason's `trigger` command to tell Travis to build, test, and publish your new package to the S3 bucket specified in `mason.sh`.

    `./mason trigger my_new_package 0.1.0`

7. Check S3 to verify whether your package exists.

## Using a package

Mason has two clients for installing and working with packages:

* **Mason cli** - comes bundled with the Mason project, see [Usage](#usage) for commands

    For example [hpp-skel](https://github.com/mapbox/hpp-skel) uses the Mason cli client and requires that the Mason version in [scripts/setup.sh](https://github.com/mapbox/hpp-skel/blob/044187fdfc441cf9db57a3c1b03972eee6882a9b/scripts/setup.sh#L6) be updated in order to stay up-to-date with the latest available packages.

* **[mason-js](https://github.com/mapbox/mason-js)** - a separate Node.js client with its own installation and usage instructions

    For example [node-cpp-skel](https://github.com/mapbox/node-cpp-skel) uses the mason-js client and pulls packages directly from S3.

_Note: The install command syntax will differ depending on the client you use._

## Mason internals

### Mason scripts

The `script.sh` file in each package is structured like the following example:

```bash
#!/usr/bin/env bash

# This is required for every package.
MASON_NAME=libuv
MASON_VERSION=0.11.29

# This is required if Mason will need to build a static library. Specify the relative path in the
# installation directory.
MASON_LIB_FILE=lib/libuv.a

# You can specify the relative path to the pkg-config file if Mason needs to build your code before
# packaging. If the library doesn't have a pkg-config file, you will need to override the functions
# `mason_cflags` and `mason_ldflags`.
MASON_PKGCONFIG_FILE=lib/pkgconfig/libuv.pc

# This is required when you need to load the build system to build your code before packaging. You
# con't need this line if you are packaging header-only code.
. ${MASON_DIR}/mason.sh

# Overriding this Mason function is required for all pakcages so Mason knows where to obtain your
# source code. This function also caches downloaded tarballs in the mason_packages/.cache folder.
function mason_load_source {
    mason_download \
        https://github.com/joyent/libuv/archive/v0.11.29.tar.gz \
        5bf49a8652f680557cbaf335a160187b2da3bf7f

    # This unpacks the archive into the `mason_packages/.build` folder. If the tarball is BZip2
    # compressed, you can also use `mason_extract_tar_bz2` instead.
    mason_extract_tar_gz

    # This variable contains the path to the unpacked folder inside the `.build` directory.
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

# Override this Mason function if you need to run code before compiling, e.g. a script that
# generates configuration files.
function mason_prepare_compile {
    ./autogen.sh
}

# It is required to override the `mason_compile` function because it performs the actual build of
# the source code (or just copies header files into a package folder to be published later for
# header-only code). This is an example of how you would configure and make a static library.
function mason_compile {
    # You must set the build system's installation prefix to `MASON_PREFIX`. For cross-platform
    # builds, you have to specify the `MASON_HOST_ARG`, which is empty for regular builds and is set
    # to the correct host platform for cross-compiles e.g. iOS builds use `--host=arm-apple-darwin`.
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    # If the build system supports building concurrently, you can tell it do do so by providing the
    # number of parallel tasks from `MASON_CONCURRENCY`.
    make install -j${MASON_CONCURRENCY}
}

# Tell Mason how to clean up the build folder. This is required for multi-architecture builds. e.g.
# iOS builds perform a Simulator (Intel architecture) build first, then an iOS (ARM architecture)
# build. The results are `lipo`ed into one universal archive file.
function mason_clean {
    make clean
}

# Run everything.
mason_run "$@"
```

### Mason variables

Name | Description
---|---
`MASON_DIR` | The directory where Mason itself is installed. Defaults to the current directory.
`MASON_ROOT` | Absolute path the `mason_packages` directory. Example: `/Users/user/mason_packages`.
`MASON_PLATFORM` | Platform of the current invocation. Currently one of `osx`, `ios`, `android`, or `linux`.
`MASON_PLATFORM_VERSION` | Version of the platform. It must include the architecture if the produced binaries are architecture-specific (e.g. on Linux). Example: `10.10`
`MASON_NAME` | Name specified in the `script.sh` file. Example: `libuv`
`MASON_VERSION` | Version specified in the `script.sh` file. Example: `0.11.29`
`MASON_SLUG` | Combination of the name and version. Example: `libuv-0.11.29`
`MASON_PREFIX` | Absolute installation path. Example: `/Users/user/mason_packages/osx-10.10/libuv/0.11.29`
`MASON_BUILD_PATH` | Absolute path to the build root. Example: `/Users/user/mason_packages/.build/libuv-0.11.29`
`MASON_BUCKET` | S3 bucket that is used for storing pre-built binary packages. Example: `mason-binaries`
`MASON_BINARIES` | Relative path to the gzipped tarball in the `.binaries` directory. Example: `osx-10.10/libuv/0.11.29.tar.gz`
`MASON_BINARIES_PATH` | Absolute path to the gzipped tarball. Example: `/Users/user/mason_packages/.binaries/osx-10.10/libuv/0.11.29.tar.gz`
`MASON_CONCURRENCY` | Number of CPU cores. Example: `8`
`MASON_HOST_ARG` | Cross-compilation arguments. Example: `--host=x86_64-apple-darwin`
`MASON_LIB_FILE` | Relative path to the library file in the install directory. Example: `lib/libuv.a`
`MASON_PKGCONFIG_FILE` | Relative path to the pkg-config file in the install directory.  Example: `lib/pkgconfig/libuv.pc`
`MASON_XCODE_ROOT` | OS X specific; Path to the Xcode Developer directory. Example: `/Applications/Xcode.app/Contents/Developer`
`MASON_HEADER_ONLY` | Set to `true` to specify this library as header-only, which bypasses building binaries (default `false`)

### Mason functions

These are common Mason function that you might need to override in your package's `script.sh` file depending on the type of library you are packaging. See https://github.com/mapbox/mason/blob/master/mason.sh to view how these functions are implemented by default. There you will find even more `mason_`-functions that you might find useful to override.

 - `mason_pkgconfig`
 - `mason_cflags`
 - `mason_ldflags`
 - `mason_static_libs`

## Troubleshooting

Downloaded source tarballs are cached in `mason_packages/.cache`. If for some reason the initial download failed, but it still left a file in that directory, make sure you delete the partial download there.
