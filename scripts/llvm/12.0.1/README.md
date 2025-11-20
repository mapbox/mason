# LLVM 12.0.1

## Building

This LLVM version uses LLVM 11.0.0 as a bootstrap compiler.

### Prerequisites

Before building LLVM 12.0.1, you need either:

**Option 1: Pre-built LLVM (faster)**
```bash
# Install LLVM 11.0.0 from S3 binaries
./mason install llvm 11.0.0
```

**Option 2: System Clang**
```bash
# Use your system's clang (macOS or Linux with clang installed)
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++
./mason build llvm 12.0.1
```

### Build Command

```bash
./mason build llvm 12.0.1
```

### Note on Bootstrap Compiler

LLVM requires a C++14 capable compiler to build. The build process:

1. Downloads LLVM 12.0.1 source
2. Uses LLVM 11.0.0 (or system clang) to compile it
3. Builds all LLVM tools (clang, clang++, clang-format, etc.)
4. Takes approximately 30-60 minutes

### Related Packages

This version provides:
- `llvm/12.0.1` - Full LLVM toolchain
- `clang++/12.0.1` - C++ compiler
- `clang-format/12.0.1` - Code formatter
- `clang-tidy/12.0.1` - Static analyzer
- `llvm-cov/12.0.1` - Code coverage tool
