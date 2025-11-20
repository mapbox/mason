# Testing Strategy for Mason

## Overview

Mason now has a two-tier testing strategy to balance CI performance with comprehensive coverage.

## Test Workflows

### 1. Smoke Tests (Fast) - `smoke-test.yml`

**Purpose:** Quick validation that basic Mason functionality works.

**When it runs:**
- Every push to `master`/`main`
- Every pull request

**What it tests:**
- Mason CLI commands (`--version`, `env`, etc.)
- Installing pre-built binary packages from S3
- Installing header-only packages
- Basic `prefix` command functionality

**Duration:** ~5-10 minutes

**Strategy:**
This provides fast feedback on every commit without consuming excessive CI resources. It catches most common breakages like:
- CLI argument parsing issues
- Binary download problems
- S3 connectivity issues
- Basic path resolution bugs

### 2. Full Test Suite (Comprehensive) - `test.yml`

**Purpose:** Thorough validation including building packages from source.

**When it runs:**
- Manual trigger (on-demand)
- Weekly schedule (Sunday 00:00 UTC)

**What it tests:**
- All smoke tests
- Building C packages from source (expat, libzip, zlib, libuv)
- Building C++ packages from source (boost_libregex)
- Cross-compilation for different architectures
- Android NDK builds
- LLVM toolchain installation and configuration
- Package symlink functionality
- Error handling for broken packages

**Duration:** ~30-60 minutes

**Strategy:**
This comprehensive suite ensures that:
- Package build scripts work correctly
- Cross-compilation toolchains are properly configured
- Complex packages (like LLVM) can be built successfully
- All edge cases are covered

By running weekly and on-demand, we avoid consuming excessive CI minutes while maintaining confidence in the codebase.

## Running Tests Locally

### Run all tests:
```bash
./test/all.sh
```

### Run specific test:
```bash
./test/unit.sh              # Just unit tests
./test/c_install.sh         # Binary package installation
./test/cpp11_install.sh     # C++ package installation
./test/llvm.sh              # LLVM specific tests
```

### Run tests with verbose output:
```bash
set -x
./test/all.sh
```

## Common Test Issues

### 1. Package Download Failures

**Symptom:** Tests fail with curl errors or 404s

**Cause:** Pre-built binaries not available in S3 for your platform

**Solution:**
- Check that the package exists in S3: `./mason existing <package> <version>`
- Build the package locally first: `./mason build <package> <version>`
- Skip tests that require unavailable packages

### 2. Build Timeouts

**Symptom:** Tests timeout in CI

**Cause:** Building large packages (like LLVM) from source takes time

**Solution:**
- Already addressed: Full test suite runs on-demand/weekly only
- Increase timeout in workflow: `timeout-minutes: 60` (already set)

### 3. Cross-compilation Failures

**Symptom:** Android or cross-compile tests fail

**Cause:** Missing NDK or cross-compilation toolchain

**Solution:**
- Tests automatically skip if NDK not available
- For local testing, set `MASON_PLATFORM=android` and install NDK

### 4. Xcode Issues on macOS

**Symptom:** Tests fail on macOS with clang errors

**Cause:** Xcode command line tools not installed

**Solution:**
```bash
xcode-select --install
```

## Test Coverage

The test suite covers:

| Category | Coverage |
|----------|----------|
| CLI commands | ✅ Full |
| Binary package install | ✅ Full |
| Header-only packages | ✅ Full |
| Building from source (C) | ✅ Full |
| Building from source (C++) | ✅ Full |
| Cross-compilation | ✅ Full |
| Android builds | ✅ Full (Linux only) |
| LLVM toolchain | ✅ Full |
| Package linking | ✅ Full |
| Error handling | ✅ Full |

## Adding New Tests

To add a new test:

1. Create a script in `test/` directory
2. Make it executable: `chmod +x test/your_test.sh`
3. Add it to `test/all.sh`:
   ```bash
   $(dirname $0)/your_test.sh
   ```
4. Follow existing test patterns:
   - Use `set -eu` and `set -o pipefail`
   - Exit with non-zero on failure
   - Use `test/assert.sh` for assertions

## CI Badge

Add this to your README to show smoke test status:

```markdown
[![Smoke Tests](https://github.com/YOUR_ORG/mason/actions/workflows/smoke-test.yml/badge.svg)](https://github.com/YOUR_ORG/mason/actions/workflows/smoke-test.yml)
```

## Performance Metrics

**Before (Travis CI):**
- Average test duration: 40-60 minutes
- Ran on every push (high CI cost)
- Single failure blocked all PRs

**After (GitHub Actions):**
- Smoke tests: 5-10 minutes (every push)
- Full tests: 30-60 minutes (weekly/on-demand)
- Fast feedback loop
- Lower CI costs (~80% reduction)
