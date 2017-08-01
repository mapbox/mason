# Mason releases

## 0.14.0

 - Added
    - libosmium cd8e2ff
    - osm-area-tools b222e00
    - geometry 0.9.2
    - supercluster 0.2.1
    -	benchmark 1.0.0, 1.1.0
    -	cheap-ruler 2.5.2, 2.5.3
    -	TBB to 2017_U7
    -	llvm 4.0.1
    -	tippecanoe 1.21.0
    - catch 1.9.6

 - Fixed
    - If mason is executed through a symlink, resolve the link

Changes: https://github.com/mapbox/mason/compare/v0.13.0...v0.14.0

## 0.13.0

 - Added
    - protozero 1.5.2
    - vector-tile 1.0.0-rc6
    - mapnik df0bbe4

Changes: https://github.com/mapbox/mason/compare/v0.12.0...v0.13.0


## 0.12.0

 - Added
    - or-tools 6.0
    - vector-tile 1.0.0-rc5
    - shelf-pack-cpp v2.0.0
    - shelf-pack-cpp v2.0.1
    - cheap-ruler 2.5.0
    - mapnik 3.0.14
    - mapnik 3.0.15
    - ccache 3.3.4
    - cmake 3.8.2
    - earcut 0.12.3

 - Removed
    - icu latest
    - mapnik latest

Changes: https://github.com/mapbox/mason/compare/v0.11.1...v0.12.0

## 0.11.1

 - Added
    - redis 3.0.7


Changes: https://github.com/mapbox/mason/compare/v0.11.0...v0.11.1

## 0.11.0

 - Added
    - libosmium 2.12.1 and libosmium 2.12.2
    - osmium-tool 1.6.1
    - additional clang-tidy tools
    - protobuf 3.3.0
    - protobuf_c 1.2.1
    - jemalloc 4.5.0
    - redis 3.2.9
    - redis 3.2.9-configurable-malloc

 - Fixed
    - unbound variables in cairo, pixman, proj, webp, boost python
    - fixed clang++ package linking when X11 is not installed (no lndir available)

Changes: https://github.com/mapbox/mason/compare/v0.10.0...v0.11.0

## 0.10.0

 - Added
    - sparsepp 0.95
    - mapnik 3.0.13-1 (Fixed build settings)
    - mapnik 3.0.13-2 (variant for profiling)
    - geojson 0.4.1, geojson 0.4.1-cxx11abi, and geojson 0.4.1-hpp
    - thelink2012/any 8fef1e9
    - postgres 9.6.2-1
    - postgis 9.6.2-1 (all contrib modules enabled)
    - glfw 2017-04-07-f40d085
    - gdb 2017-04-08-aebcde5
 - Fixed
    - unbound variable in or-tools

Changes: https://github.com/mapbox/mason/compare/v0.9.0...v0.10.0

## 0.9.0

 - Added
    - mapnik 3.0.13
    - Android NDK r14
    - ninja 1.7.2
    - llvm/clang++ 4.0.0 (official tag, previous package was against dev build)
    - sqlite 3.17.0
    - wagyu 0.4.2
    - geometry 0.9.1
    - icu 57
    - postgres 9.6.2
    - postgis 2.3.2
    - libxml2 2.9.4
    - geos 3.6.1

Changes: https://github.com/mapbox/mason/compare/v0.8.0...v0.9.0

## 0.8.0

 - Added
    - tippecanoe 1.16.9
    - libzmq 4.2.2
    - cppzmq 4.2.1
    - glfw 2017-02-09-77a8f10
    - zstd 1.1.3
    - wagyu 0.4.0
    - cxx11 ABI version of gtest 1.8.0
    - node v4.7.3
    - node v6.9.5
    - stxxl 1.4.1-1
    - libshp2 1.3.0 (shapelib)
    - icu 58.1-min-size (built with -Os)
    - binutils 2.28
    - libosmium 2.12.0
    - osmium-tool 1.6.0
    - harfbuzz 1.4.4-ft
    - perf 4.9.9
    - elfutils 0.168
    - slang 2.3.1
    - xz 5.2.3
    - sdf-glyph-foundry 0.1.0
    - sdf-glyph-foundry 0.1.1

 - Removed
    - tippecanoe 1.9.7 (never worked, never had binaries published)
    - gcc 4.9.2-{i686,cortex_a9,cortex_a9-hf}
    - wagyu 0.1.0

 - Fixed
    - Man files are now provided for osmium-tool 1.5.1
    - binutils 2.27 now builds on os x
    - Unbound variables in sparsehash, bzip2, and harfbuzz packages
    - mason now run with `set -u` to catch undefined variables in scripts
    - config generation that fails now stops build

Changes: https://github.com/mapbox/mason/compare/v0.7.0...v0.8.0

## 0.7.0

 - Added
    - or-tools 5.1
    - jni.hpp 3.0.0
    - libpng 1.6.28
    - jpeg turbo 1.5.1
    - freetype 2.7.1
    - harfbuzz 1.4.2 (links no deps)
    - harfbuzz 1.4.2-ft (links freetype 2.7.1)
    - libpq and postgres 9.6.1
    - webp 0.6.0
    - protobuf 3.2.0
    - proj 4.9.3
    - libtiff 4.0.7
    - gdal 2.1.3
    - cairo 1.14.8
    - geojsonvt 6.2.0
    - tbb 2017_20161128
    - kdbush 0.1.1-1
    - benchmark 1.0.0-1
    - jni 2.0.0-1
    - earcut 0.12.2
    - libgdal 2.1.3 (minimal package of just headers, lib, data)

 - Fixed
    - gcc 5.3.0-i686 lib file corrected
    - unique_resource pinned to cba309e
    - gdal-config to work even if not linked
    - api-trace now built with g++-5

Changes: https://github.com/mapbox/mason/compare/v0.6.0...v0.7.0

## 0.6.0

 - Added valgrind 3.12.0, earcut 0.12.1, protozero 1.5.0/1.5.1,
   libprogram_options 1.62.0-cxx11abi, jemalloc 4.4.0, llnode 1.4.1,
   Omnibus mesa 13.0.3, cmake 3.7.2, minjur 0.1.0, libosmium, 2.11.0,
   tippecanoe 1.16.3, sqlite 3.16.2, osmium-tool 1.5.1, apitrace 6a30de1,
   nsis 3.01, llvm-argdumper and lldb-server to lldb package
 - Removed valgrind latest, minjur latest, tippecanoe latest
 - Fixed harfbuzz package (#327), boost_regex_icu variant

Changes: https://github.com/mapbox/mason/compare/v0.5.0...v0.6.0

## 0.5.0

 - Various fixes to support cross compiling
 - Support for cross compiling to cortex_a9 on travis
 - Added vector-tile 1.0.0-rc4, zlib_shared 1.2.8
 - Fixes to zlib 1.2.8 ldflags

Changes: https://github.com/mapbox/mason/compare/v0.4.0...v0.5.0

## 0.4.0

 - Now defaulting to clang 3.9.1 for building binaries
 - clang++ binaries no longer distribute libc++ headers on OS X (instead they depend on system)
 - Reduced size of v8 libs by striping debug symbols
 - Fixed minjur latest package to build in Release mode
 - Added polylabel 1.0.2, protozero 1.4.5, rocksdb v4.13, libosmium 2.10.3, llvm 3.9.1,
   boost 1.63.0, cmake 3.7.1, cairo 1.14.6, freetype 2.6.5, harfbuzz 1.3.0, jpeg_turbo 1.5.0,
   libpng 1.6.24, pixman 0.34.0, sqlite 3.14.1, twemproxy 0.4.1,
 - Removed llvm 3.8.0, clang 3.8.0, llvm 3.9.0, luabind, luajit
 - Rebuilt libpq 9.5.2, libtiff 4.0.6, utfcpp 2.3.4, minjur latest

Changes: https://github.com/mapbox/mason/compare/v0.3.0...v0.4.0

## 0.3.0

 - Updated android compile flags
 - Added v8 `5.1.281.47` and `3.14.5.10`
 - Fixed boost library name reporting
 - Added tippecanoe `1.15.1`
 - Added `iwyu` and `asan_symbolize` python script to llvm+clang++ packages

Changes: https://github.com/mapbox/mason/compare/v0.2.0...v0.3.0

## 0.2.0

 - Added icu 58.1, mesa egl, boost 1.62.0, gdb 7.12, Android NDK r13b, binutils latest,
   variant 1.1.4, geometry 0.9.0, geojson 0.4.0, pkgconfig 0.29.1, wagyu 1.0
 - Removed boost *all* packages
 - Renamed `TRAVIS_TOKEN` to `MASON_TRAVIS_TOKEN`
 - Now including llvm-ar and llvm-ranlib in clang++ package
 - Now setting secure variables in mason rather than .travis.yml per package

Changes: https://github.com/mapbox/mason/compare/v0.1.1...v0.2.0

## 0.1.1

 - Added binutils 2.27, expat 2.2.0, mesa 13.0.0, and llvm 4.0.0 (in-development)
 - Improved mason.cmake to support packages that report multiple static libs
 - Improved llvm >= 3.8.1 packages to support `-flto` on linux

## 0.1.0
 - First versioned release
