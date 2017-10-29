# llvm

This readme documents:

 - How the llvm packages are structured
 - Which sub-packages depend on the llvm package
 - How the llvm packages are built
 - How to create a new llvm package + sub-packages
 - How to use the binary packages

## How the llvm packages are structured

This llvm/base directory is not a package itself, but two critical building blocks:

 - `scripts/llvm/base/README.md`: this document, that explains how to understand, use, and build the llvm package and sub-packages
 - `scripts/llvm/base/common.sh`: a common set of bash functions that are inherited by each llvm package.

A given llvm package version is what users of mason actually request: e.g. llvm 4.0.0. This package lives at `scripts/llvm/4.0.0/script.sh`.

A user can install that version like:

```
mason install llvm 4.0.0
```

However, if they do they will get over 1.6 GB of binaries. See below to learn about the subpackages.

## Which sub-packages depend on the llvm package

To enable faster and smaller installs, we provide sub-packages that provide specific working parts of llvm. The available sub-packages are:

 - `clang++`: The clang++ (C++) and clang (C) compiler in one package - https://clang.llvm.org. Also includes:
  - https://compiler-rt.llvm.org/ for sanitizer support
  - `libLTO` for link time optimization support - https://www.llvm.org/docs/LinkTimeOptimization.html#liblto (needs binutils >= 2.27)
 - `clang-format`: command line tool to do automatic source code formatting based on Clang - https://clang.llvm.org/docs/ClangFormat.html
 - `clang-tidy`: a clang-based C++ “linter” tool. Its purpose is to provide an extensible framework for diagnosing and fixing typical programming errors, like style violations, interface misuse, or bugs that can be deduced via static analysis - https://clang.llvm.org/extra/clang-tidy
 - `include-what-you-use`: A tool for use with clang to analyze #includes in C and C++ source files - https://include-what-you-use.org
 - `lldb`: LLDB is a next generation, high-performance debugger - https://lldb.llvm.org
 - `llvm-cov`:

These subpackages use custom bash scripts that also inherit from a `base/common.sh`. For example for the `clang++` sub-package this is `scripts/clang++/base/common.sh`. This design makes it possible to create new versions of the packages, by copying a specific verison, without modifying needing to modify the `script.sh` (the version is automatically detected from their directory name).


## How the llvm packages are built

They are built locally by a Mason contributor, rather than on https://travis-ci.org. The reason is that travis is not fast enough for the llvm compile.

### OS X details

On MacOS we build for OS X 10.12 as the minimum target. We link llvm against the apple system libc++.

On OS X you additionally have to set up code signing once on the machine that builds llvm: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt

### Linux details

On Linux we build using an Ubuntu Precise docker image in order to ensure that binaries can be run on Ubuntu Precise and newer platforms.

We link clang++ and other llvm c++ tools to libc++ (the one within the build) to avoid clang++ itself depending on a specific libstdc++ version.

The clang++ binary still defaults to building and linking linux programs against libstdc++.


## How to create a new llvm package + sub-packages

### Pre-requisites

If you would like to create a new llvm package, when a new version is created, you will need:

 - Docker installed
 - At least 1 hour free to run builds locally
 - A fast internet connection for large uploads (> 1.6 GB)
 - A host machine of either Linux or OS X
 - If using OS X then the machine needs to be set up for signing (https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt)

Here are the steps to create a new llvm version:

#### Step 1: Note the latest release

Go to http://releases.llvm.org to see the latest release. For our walkthrough below we will assume that the new release is `4.0.2`.

#### Step 2: Make sure this release of llvm is not already packaged

Check to see if there is not already a `scripts/llvm/4.0.2`.

#### Step 3: Create a mason branch

Create a new branch called `llvm-4.0.2`.

#### Step 4: Create the new package

Top create new version of the llvm package and sub-packages do:

```
./utils/llvm.sh create 4.0.2 4.0.1
```

#### Step 5: Push packages to github and create PR

First add the new package and sub-packages to git

```
git add scripts/*/4.0.2/*
```

Now push to github:

```
git push origin llvm-4.0.2
```

Then go create a PR.

#### Step 6: Build and publish the new llvm package and sub-packages

This step will vary depending on your host operating system.

If you are on OS X, then you will first build the package locally to produce the OS X version. Then you will build the package a second time inside a linux docker container to produce the linux version.

If you are on Linux, then you will first build the package in the linux docker container. Then you will ping a co-worker to help build the package on OS X if you do not have access to an OS X machine.

##### OS X

A. First build the llvm package. This may take > 30 minutes.

```
./mason build llvm 4.0.2
```

B. Then build all the sub-packages. This will be fast since they are simply repackaged binaries.

```
./utils/llvm.sh build 4.0.2
```

C. Authenticate your shell with the mason AWS KEYS

```
export AWS_ACCESS_KEY_ID=<>
export AWS_SECRET_ACCESS_KEY=<>
```

D. Then publish the main llvm package and sub-packages. This may take > 20 min depending on the speed of your internet connection.

```
./mason publish llvm 4.0.2
./utils/llvm.sh publish 4.0.2
```

##### Linux

A. Build the docker image

```
docker build -t mason-llvm -f utils/Dockerfile.llvm .
```

B. Run the docker image

We run the docker image to build the package on linux. We map volumes such that the binary will end up on our host machine (to avoid needing to pass publishing credentials to docker).

```
LLVM_VERSION="4.0.2"
docker run -it --volume $(pwd):/home/travis/build/mapbox/mason mason-llvm \
  /bin/bash -c "./mason build llvm ${LLVM_VERSION} && ./utils/llvm.sh build ${LLVM_VERSION}"
```

C. Authenticate your shell with the mason AWS KEYS

```
export AWS_ACCESS_KEY_ID=<>
export AWS_SECRET_ACCESS_KEY=<>
```

D. Then publish the main llvm package and sub-packages. This may take > 20 min depending on the speed of your internet connection.

```
MASON_PLATFORM=linux ./mason publish llvm 4.0.2
MASON_PLATFORM=linux ./utils/llvm.sh publish 4.0.2
```

Note: `MASON_PLATFORM=linux` is only needed if your host is OS X.

## How to use the binary packages

The binary packages will work on:

- >= Ubuntu precise
- OS X >= 10.12
- XCode >= 8 installed to `/Applications/Xcode.app` such that `xcode-select -p` returns `/Applications/Xcode.app/Contents/Developer`

### LTO support

If you want to use `-flto` support with clang++ you also need to install binutils >= 2.27. To see the exact version of binutils that llvm was built against look inside the `scripts/llvm/base/common.sh` (https://github.com/mapbox/mason/blob/llvm-4.0.1/scripts/llvm/base/common.sh#L127).

### Xcode missing

It is recommended that you install XCode >= 8. In the rare situation that you cannot, or when you don't have Xcode installed in `/Applications`, you may be able to get clang++ working by:

1) Adding `-isysroot` compiler argument to point at your Mac SDK (the value returned from `xcrun --show-sdk-path`)

2) Adding an include flag to point at your C++ headers which are generally at `ls $(dirname $(xcrun --find clang++))/../include/c++/v1`. For the command line tools this directory is at `/Library/Developer/CommandLineTools/usr/include/c++/v1/`

For `make` based systems this might work:

```
export CXXFLAGS="-isysroot $(xcrun --show-sdk-path) -I$(dirname $(xcrun --find clang++))/../include/c++/v1"
```

