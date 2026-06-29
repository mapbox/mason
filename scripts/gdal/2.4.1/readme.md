## Packaging GDAL

### Background

GDAL is one of the harder software libraries to package because it has so many required and potential dependencies.

Also, mason prefers packaging libraries at static archives, which complicates things because this complicates dependency handling: when linking to static libraries you need all of the libraries (passed to the linker) that static archive depends on. For GDAL that is both the C standard library, the C++ standard library, and potentially a lot of libraries other libraries, both with C and C++ dependencies. This is the main reason that the script.sh is so narly. The upside is that then the libraries are standalone at runtime. So, hard to build, easy to run. It's a tradeoff

### Steps to package

This document intends to guide you to the basic steps to package a new version of GDAL in mason.

#### Step 1: Copy a previous GDAL package.

Find the last successful package gdal mason. Perhaps use the highest incremented version:

```
ls scripts/gdal/
1.11.1	1.11.1-big-pants  1.11.2  2.0.2  2.1.1	2.1.3  2.2.1  2.2.2  2.2.3  2.2.3-1  2.4.1  dev
```

It is `2.2.3-1` at the time of this writing.

Then find most recent release at http://download.osgeo.org/gdal/

Create new package:

```
cd mason
cp -r scripts/gdal/2.2.3-1 scripts/gdal/2.4.1
```

Open up `scripts/gdal/2.4.1/script.sh` and edit the `MASON_VERSION` variable to be `2.4.1`

#### Step 2: Now try building

This will fail with an error, but just do it anyway:

```
./mason build gdal 2.4.1
```

The error is because the hash changed for the upstream download, because you changed the `MASON_VERSION`.

You will see an error like:

> Hash 38758d9fa5083e8d8e4333c38e132e154da9f25f of file /Users/danespringmeyer/projects/mason/mason_packages/.cache/gdal-2.4.1 doesn't match f4ac4fb76e20cc149d169163914d76d51173ce82

To fix this, edit `scripts/gdal/2.4.1/script.sh` and add the first hash reported on `line 12`.

Now try building again:

```
./mason build gdal 2.4.1
```

If it succeeded locally then you are good to continue to the next step.


#### Step 3: push to github and build on travis

First create a new mason branch and push all the new scripts:

```
git checkout -b gdal-2.4.1
git add scripts/gdal
git commit scripts/gdal -m "adding GDAL 2.4.1"
```

Then try triggering a build on travis. To do this do:

```
./mason trigger gdal 2.4.1
```

And you watch for the build job to appear at https://travis-ci.org/mapbox/mason/builds. It wll have a "lego" icon and a title like "Building gdal 2.4.1", which denotes a triggered build.
