
## 0.2.0

 - Added icu 58.1, mesa egl, boost 1.62.0, gdb 7.12, Android NDK r13b, binutils latest,
   variant 1.1.4, geometry 0.9.0, geojson 0.4.0, pkgconfig 0.29.1, wagyu 1.0
 - Removed boost *all* packages
 - Renamed `TRAVIS_TOKEN` to `MASON_TRAVIS_TOKEN`
 - Now including llvm-ar and llvm-ranlib in clang++ package
 - Now setting secure variables in mason rather than .travis.yml per package

## 0.1.1

 - Added binutils 2.27, expat 2.2.0, mesa 13.0.0, and llvm 4.0.0 (in-development)
 - Improved mason.cmake to support packages that report multiple static libs
 - Improved llvm >= 3.8.1 packages to support `-flto` on linux

## 0.1.0
 - First versioned release