# Quick Start: Building LLVM

## TL;DR - Build LLVM 17 Right Now

```bash
# Set environment variables
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++

# Build (will take 30-60 minutes)
./mason build llvm 17.0.6
```

## What Was Fixed

### Problem
The LLVM build was getting stuck in a loop trying to download and build itself recursively.

### Root Causes
1. **Recursive dependency**: LLVM needed LLVM 11.0.0 to build, which doesn't exist for arm64
2. **Wrong source structure**: The old build script downloaded separate component tarballs, but LLVM 12+ uses a unified monorepo
3. **Custom compiler ignored**: Even when `CUSTOM_CC/CXX` were set, the script still tried to install LLVM

### Solutions Applied
✅ All LLVM versions (12.0.1, 13.0.1, 14.0.6, 16.0.6, 17.0.6) now:
- Use the **monorepo tarball** (single download)
- **Require `CUSTOM_CC/CXX`** to be set (or fail with helpful error)
- Skip bootstrap LLVM install when using system compiler
- Use modern CMake options for monorepo structure

## Building Each Version

All versions now work the same way:

```bash
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++

# Choose your version
./mason build llvm 12.0.1  # ~30-60 min
./mason build llvm 13.0.1  # ~30-60 min
./mason build llvm 14.0.6  # ~40-70 min
./mason build llvm 16.0.6  # ~40-80 min
./mason build llvm 17.0.6  # ~40-80 min
```

## What Gets Built

Each LLVM package includes:

- **clang** - C/C++ compiler
- **clang++** - C++ compiler (same as clang)
- **clang-format** - Code formatter
- **clang-tidy** - Static analyzer
- **lldb** - Debugger
- **lld** - Linker
- **llvm-cov** - Code coverage
- **polly** - Loop optimizer
- **compiler-rt** - Runtime libraries
- **libc++** - C++ standard library
- **openmp** - OpenMP runtime

## Dependencies Auto-Installed

The build automatically installs:
- CMake 3.21.2
- Ninja 1.10.1
- ccache 4.0
- libedit 3.1
- ncurses 6.1
- binutils 2.35 (Linux only)

## Build Process

```
1. Download monorepo tarball (~200MB compressed, ~2GB extracted)
   ↓
2. Install dependencies (CMake, Ninja, etc.)
   ↓
3. Configure with CMake (~2-5 minutes)
   ↓
4. Build with Ninja (~25-75 minutes depending on version/CPU)
   ↓
5. Install to mason_packages/osx-arm64/llvm/{version}/
   ↓
6. Build sanitizer variants of libc++ (~5-10 minutes)
```

## Verify Build Succeeded

```bash
# Check installation path
./mason prefix llvm 17.0.6

# Test the compiler
$(./mason prefix llvm 17.0.6)/bin/clang++ --version

# Compile a test program
echo 'int main() { return 0; }' | $(./mason prefix llvm 17.0.6)/bin/clang++ -x c++ - -o /tmp/test
/tmp/test && echo "Success!"
```

## Troubleshooting

### "requires a C++XX compiler" error

You forgot to set the environment variables:
```bash
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++
```

### Build gets stuck

Kill it (Ctrl+C) and check:
```bash
# Clear any partial builds
rm -rf mason_packages/.build/llvm-*

# Try again
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++
./mason build llvm 17.0.6
```

### "cmake: command not found"

Mason will download CMake automatically, but if that fails:
```bash
# Install cmake first
./mason install cmake 3.21.2
```

### Build runs out of disk space

LLVM builds need ~10-15GB of free space. Clear some space and try again.

### Build runs out of memory

Reduce parallelism:
```bash
export MASON_CONCURRENCY=2  # Use only 2 cores instead of all cores
./mason build llvm 17.0.6
```

## Quick Reference

| Version | Monorepo? | Min C++ | Build Time | Size |
|---------|-----------|---------|------------|------|
| 12.0.1  | ✅ Yes    | C++14   | 30-60 min  | ~2GB |
| 13.0.1  | ✅ Yes    | C++14   | 30-60 min  | ~2GB |
| 14.0.6  | ✅ Yes    | C++14   | 40-70 min  | ~2.5GB |
| 16.0.6  | ✅ Yes    | C++17   | 40-80 min  | ~3GB |
| 17.0.6  | ✅ Yes    | C++17   | 40-80 min  | ~3GB |

## After Building

Once built, you can use the LLVM package:

```bash
# Use in your project
export LLVM_ROOT=$(./mason prefix llvm 17.0.6)
export CC=$LLVM_ROOT/bin/clang
export CXX=$LLVM_ROOT/bin/clang++

# Or get compiler flags
./mason cflags llvm 17.0.6
./mason ldflags llvm 17.0.6
```

That's it! Simple and straightforward now. 🎉
