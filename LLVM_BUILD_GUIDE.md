# LLVM Build Guide

## Problem: Recursive Dependency Loop

When building new LLVM versions (12+), Mason gets stuck in an infinite loop because:

1. LLVM needs LLVM to build itself (bootstrap compiler)
2. The default bootstrap version (9.0.1) also needs bootstrapping
3. This creates a recursive dependency

## Solution: Fixed Bootstrap Compiler

All new LLVM versions (12.0.1, 13.0.1, 14.0.6, 16.0.6, 17.0.6) now use **LLVM 11.0.0** as their bootstrap compiler, which breaks the recursion.

## How to Build LLVM

### Method 1: Install Bootstrap LLVM First (Recommended)

```bash
# Step 1: Install LLVM 11.0.0 from S3 (if available)
./mason install llvm 11.0.0
./mason install clang++ 11.0.0

# Step 2: Build your desired version
./mason build llvm 12.0.1
```

### Method 2: Use System Clang

If LLVM 11.0.0 is not available in S3, use your system's clang:

```bash
# Set environment variables to use system clang
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++

# Build LLVM
./mason build llvm 12.0.1
```

### Method 3: Build Chain from Scratch

If you need to build everything from scratch:

```bash
# Build LLVM 11.0.0 first using system clang
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++
./mason build llvm 11.0.0

# Then build newer versions using 11.0.0
unset CUSTOM_CC CUSTOM_CXX
./mason build llvm 12.0.1
./mason build llvm 13.0.1
./mason build llvm 14.0.6
# ... etc
```

## Build Time Estimates

| Package | Typical Build Time | Size |
|---------|-------------------|------|
| LLVM 12.0.1 | 30-60 minutes | ~2GB |
| LLVM 13.0.1 | 30-60 minutes | ~2GB |
| LLVM 14.0.6 | 30-70 minutes | ~2.5GB |
| LLVM 16.0.6 | 40-80 minutes | ~3GB |
| LLVM 17.0.6 | 40-80 minutes | ~3GB |

*Times vary based on CPU cores and disk speed*

## Dependencies

Each LLVM build automatically installs:

- **CMake** 3.21.2
- **Ninja** 1.10.1
- **ccache** 4.0
- **libedit** 3.1
- **ncurses** 6.1
- **binutils** 2.35 (Linux only)

## Build Process

1. **Download source** - Downloads LLVM source from GitHub releases
2. **Install dependencies** - Installs CMake, Ninja, ccache, etc.
3. **Install bootstrap compiler** - Installs LLVM 11.0.0
4. **Configure** - Runs CMake with optimized settings
5. **Build** - Compiles LLVM, Clang, and tools (this takes the longest)
6. **Install** - Installs to `mason_packages/{platform}/llvm/{version}/`

## Troubleshooting

### Build gets stuck in a loop

**Symptom:** Build keeps trying to install LLVM repeatedly

**Solution:**
- Kill the build (Ctrl+C)
- Install LLVM 11.0.0 first: `./mason install llvm 11.0.0`
- Try building again

### Bootstrap LLVM not available in S3

**Symptom:** `Failed to download binary package`

**Solution:**
- Use system clang instead (see Method 2 above)
- Or build LLVM 11.0.0 first using system clang

### Build fails with "compiler not found"

**Symptom:** `clang++: command not found`

**Solution:**
- Ensure you have Xcode Command Line Tools (macOS):
  ```bash
  xcode-select --install
  ```
- Or install build-essential (Linux):
  ```bash
  sudo apt-get install build-essential
  ```

### Build runs out of memory

**Symptom:** Build killed with "Killed" message

**Solution:**
- Close other applications
- Reduce parallelism: `export MASON_CONCURRENCY=2`
- Build on a machine with more RAM (8GB+ recommended)

### Build times out in CI

**Symptom:** GitHub Actions timeout after 60 minutes

**Solution:**
- Don't build LLVM in CI for every commit
- Use pre-built binaries from S3
- Build LLVM locally and publish to S3
- Or increase timeout in workflow

## Related Packages

Each LLVM version includes these tools:

### Core Package
- **llvm/{version}** - Full LLVM toolchain

### Derived Packages (built from same source)
- **clang++/{version}** - C++ compiler
- **clang-format/{version}** - Code formatter
- **clang-tidy/{version}** - Static analyzer
- **llvm-cov/{version}** - Code coverage tool

All these share the same build and use the main LLVM package.

## Testing LLVM Builds

### Quick test

```bash
# Check LLVM was installed
./mason prefix llvm 12.0.1

# Test the compiler
$(./mason prefix llvm 12.0.1)/bin/clang++ --version
```

### Full test

```bash
# Create a test C++ file
cat > test.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello from LLVM!" << std::endl;
    return 0;
}
EOF

# Compile with new LLVM
$(./mason prefix llvm 12.0.1)/bin/clang++ -std=c++14 test.cpp -o test

# Run
./test
```

## Advanced: Custom Build Options

To customize the LLVM build, you can override environment variables:

```bash
# Use custom compiler
export CUSTOM_CC=/path/to/clang
export CUSTOM_CXX=/path/to/clang++

# Adjust parallelism (default: number of CPU cores)
export MASON_CONCURRENCY=4

# Build with debug symbols (not recommended, very large)
export CMAKE_BUILD_TYPE=Debug

./mason build llvm 12.0.1
```

## Publishing to S3

Once you've successfully built LLVM locally:

```bash
# Ensure AWS credentials are configured
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# Publish to S3
./mason publish llvm 12.0.1
```

Or use the GitHub Actions workflow (see `.github/workflows/package-builder.yml`).

## Summary

✅ **Fixed:** LLVM versions now use 11.0.0 as bootstrap compiler
✅ **No more loops:** Recursive dependency resolved
✅ **Three methods:** Bootstrap install, system clang, or build chain
✅ **Documented:** Build times, dependencies, and troubleshooting

Happy building! 🛠️
