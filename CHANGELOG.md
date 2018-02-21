# Mason releases

## 0.18.0

- Added
  - android-ndk r16b
  - args 6.2.0
  - bcc e6c7568
  - benchmark 1.3.0, 1.3.0-cxx11abi
  - binutils 2.30
  - boost 1.66.0 (includes boost_libatomic, boost_libchrono, boost_libdate_time, boost_libfilesystem, boost_libiostreams, boost_libprogram_options, boost_libpython, boost_libregex, boost_libregex_icu, boost_libregex_icu57, boost_listsystem, boost_libtest, boost_libthread)
  - build2 0.7.0-a.0.1517662481.a542a12b9195bb49
  - gdal 2.2.3-1 (with geos enabled)
  - jq 1.5-239278fd
  - libcurl 7.50.2
  - libedit 3.1
  - libnghttp2 1.26.0
  - llvm 7.0.0. 5.0.1 (includes clang++, clang-format, clang-tidy, include-what-you-use, llvm-cov)
  - mapnik 3.0.18, 3.0.17, 3.0.16, a2f5969
  - ncurses 6.1
  - optional f27e7908
  - osm-tag-rewriter 1.1.1
  - perf 4.15
  - protozero 1.6.1
  - spatial-algorithms 0.1.0, cdda174
  - tao_tuple 28626e99
  - tippecanoe 1.27.6
  - vector-tile 1.0.1, f4728da
  - vtzero 533b811, f6efb8e, 7adde32
  - wget 1.19.2

- Changed
  - Updated llvm documentation
  - Updated download path for libpng 1.6.28
  - Create .ccache directory in container to allow mapping volume
  - Mason tests default to precise
  - Various style fixes in mason.sh [#489](https://github.com/mapbox/mason/pull/489)
  - Advances to llvm packaging [30c4647](https://github.com/mapbox/mason/commit/30c4647d0d80439d8b6017f519d13812a9fe986b)
    - now building sanitized libc++ (asan, msan, and tsan)
    - now building libc++/c++abi on all platforms
    - still not installing libc++ on osx (to avoid conflicts with system)
    - now ensuring we build using mason clang++
    - upgraded build dependencies
    - added support for building lldb against libedit and libncurses
    - simplify and robustify package installs (no longer by default building iwyu)
    - longer installing install-xcode-toolchain

Changes: https://github.com/mapbox/mason/compare/v0.17.0...v0.18.0


## 0.17.0

- Added
  - gdal 2.2.3 and sub-packages:
    - ogr2ogr 2.2.3
    - libgdal 2.2.3
  - mapnik 98c26bc (https://github.com/mapnik/mapnik/commit/98c26bc)
  - build2 0.6.2 (https://build2.org)

- Changed
  - Now compiling packages with clang++-5 on travis


## 0.16.0
- Added
  - abseil 56e782
  - clang-format 6.0.0
  - clang-tidy 6.0.0
  - clang++ 6.0.0
  - earcut 0.12.4
  - expat 2.2.4
  - gdal 2.2.2
  - geojsonvt 6.3.0
  - geometry 57920c8
  - geometry 96d3505
  - geos 3.6.2
  - gzip a4cfa6a638de351d26834cf2fea373693cdaa927
  - include-what-you-use 6.0.0
  - jpeg_turbo 1.5.2
  - json-c 0.12.1
  - libgdal 2.2.2
  - libosmium 2.13.1
  - libpng 1.6.32
  - libpq 9.6.5
  - libtiff 4.0.8
  - libxml 2.9.6
  - lldb 6.0.0
  - llvm-cov 6.0.0
  - ogr2ogr 2.2.2
  - openfst 1.6.3
  - osmium-tool 1.7.1
  - osmium-tool 1.7.1-1
  - postgis 2.4.0
  - postgis 2.4.1
  - postgres 9.6.5
  - protobuf 3.4.1
  - protobuf_c 1.3.0
  - protozero 1.5.3
  - protozero 1.6.0
  - protozero a0e9109
  - protozero ccf6c39
  - re2 2017-08-01
  - spatial-algorithms 2904283
  - spatial-algorithms 3b46e05
  - tippecanoe 1.26.0
  - variant 1.1.5
  - vector-tile b756a6e
  - vector-tile 0390175
  - vtzero 07fe353
  - vtzero 556fac5
  - vtzero 7455d08
  - vtzero e651b70
  - vtzero fa6682b

- Fixed
  - Improve Mason error handling https://github.com/mapbox/mason/commit/1727795f314dbef66fb0f84ee98a82a62e77b5d1
  - Fix Docker invocation https://github.com/mapbox/mason/commit/66817048a3f5613c14838920df237e781c7a4b99
  - PKG_CONFIG_PATH env var fix https://github.com/mapbox/mason/pull/493/files
  - Set BOOST_TOOLSET* from CC and CXX env variables https://github.com/mapbox/mason/pull/499
  - llvm 6.x / current unreleased HEAD https://github.com/mapbox/mason/pull/497
  - Change to use OSX sym linked location for SDK [#477](https://github.com/mapbox/mason/pull/477)
  - Documentation for how to add packages [commit](https://github.com/mapbox/mason/commit/d43bb42c71c2a56eba1c063d1333fbf73e3bd0d4)
  - cairo 1.14.8 - Remove `-Wmissing-declarations` from CAIRO_CFLAGS_DEFAULTS [#491](https://github.com/mapbox/mason/pull/491)
  - boost 1.61.0, 1.62.0, 1.63.0, 1.64.0, 1.65.1 - Set BOOST_TOOLSET* from CC and CXX env variables [#499](https://github.com/mapbox/mason/pull/499)
  - ragel 6.9 - Add -std=gnu++98 to CXXFLAGS [#494](https://github.com/mapbox/mason/pull/494)
  - harfbuzz 0.9.40, 0.9.41, 1.1.2, 1.2.1, 1.2.6, 1.3.0, 1.4.2-ft, protobuf_c 1.1.0 - Do not assume PKG_CONFIG_PATH to be defined [#493](https://github.com/mapbox/mason/pull/493)


## 0.15.0

 - Added
    - vtzero fa6682b
    - protozero a0e9109
    - libosmium 2.13.1
    - osmium-tool 1.7.1
    - benchmark 1.2.0
    - boost 1.65.1
    - llvm 5.0.0
    - geojson 0.4.2
    - gdal 2.2.1
    - boost 1.64.0
 - Fixed
    - v8 5.1.281.47 now build without snapshot functionality
    - Fixed undefined vars in mesa, minjur, android-ndk, boost python, and apitrace packages

Changes: https://github.com/mapbox/mason/compare/v0.14.2...v0.15.0


## 0.14.2

 - Added
    - vector-tile 1.0.0-rc7
    - geojsonvt 6.2.1
    - polylabel 1.0.3
    - shelf-pack 2.1.1
    - supercluster 0.2.2
    - wagyu 0.4.3
    - rocksdb 5.4.6
    - tippecanoe 1.22.1

  - Fixed
    - webp 0.6.0 now built for iOS

Changes: https://github.com/mapbox/mason/compare/v0.14.0...v0.14.1


## 0.14.1

 - Added
    - Detailed readme on how to package llvm in mason
    - llvm 4.0.1 and subpackages:
        - clang++
        - clang-tidy
        - clang-format
        - lldb
        - llvm-cov
        - include-what-you-use

Changes: https://github.com/mapbox/mason/compare/v0.14.0...v0.14.1

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
