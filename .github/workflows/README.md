# GitHub Actions Workflows

This directory contains GitHub Actions workflows for Mason package management.

## Workflows

### `package-builder.yml`
Builds and publishes Mason packages to S3. This replaces the previous Travis CI-based build system.

**Usage:**
1. Go to the Actions tab in GitHub
2. Select "Build and Publish Package"
3. Click "Run workflow"
4. Enter the package name (e.g., `llvm`)
5. Enter the package version (e.g., `11.0.0`)
6. Select the platform (all, linux, or macos)
7. Click "Run workflow"

**Requirements:**
- Repository secrets must be configured with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Package scripts must exist at `scripts/{package_name}/{package_version}/`

**⚠️ Important:** This publishes to S3! For testing builds without publishing, use `test-package-builder.yml` instead.

### `test-package-builder.yml`
Test version of package-builder that builds packages WITHOUT publishing to S3.

**Usage:**
1. Go to the Actions tab in GitHub
2. Select "Test Package Builder (Dry Run)"
3. Click "Run workflow"
4. Enter package name and version (defaults: zlib 1.2.8)
5. Select platform
6. Click "Run workflow"

**Features:**
- ✅ Tests package build process
- ✅ Verifies package scripts exist
- ✅ Uploads build artifacts
- ✅ No AWS credentials needed
- ✅ No S3 publishing

**When to use:**
- Testing new package versions before publishing
- Debugging build issues
- Verifying checksums are correct
- Testing workflow changes

See [TESTING_PACKAGE_BUILDER.md](../TESTING_PACKAGE_BUILDER.md) for detailed guide.

### `smoke-test.yml`
Runs quick smoke tests to verify basic Mason functionality.

**Triggers:**
- Push to `master` or `main` branch
- Pull requests to `master` or `main` branch

**Tests:**
- Unit tests (mason commands)
- Basic package installation (binary packages)
- Header-only package installation

**Duration:** ~5-10 minutes

**Platforms:**
- Ubuntu 22.04
- macOS 13

### `test.yml`
Runs the comprehensive Mason test suite including building packages from source.

**Triggers:**
- Manual trigger via `workflow_dispatch`
- Weekly schedule (Sunday at 00:00 UTC)

**Tests:**
- All smoke tests
- Building packages from source (C and C++ packages)
- Cross-compilation tests
- Android build tests (Linux only)
- LLVM installation tests
- Package linking tests

**Duration:** ~30-60 minutes

**Platforms:**
- Ubuntu 22.04
- macOS 13

**Note:** This comprehensive test suite is run on-demand or weekly to avoid consuming excessive CI minutes on every push.

## Migration from Travis CI

Previously, Mason used Travis CI with per-package `.travis.yml` files. The new GitHub Actions approach:

1. **Centralized workflows**: All builds use the same workflow definition
2. **Manual triggers**: Packages are built on-demand via workflow_dispatch
3. **Better debugging**: Build logs and artifacts are preserved on failure
4. **Modern infrastructure**: Uses current GitHub Actions runners

## Creating a New Package

When adding a new package version:

1. Create the package directory: `scripts/{name}/{version}/`
2. Add `script.sh` with build instructions
3. Test locally: `./mason build {name} {version}`
4. Trigger the GitHub Actions workflow to build and publish

No need to create per-package CI configuration files.
