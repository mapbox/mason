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

### `test.yml`
Runs the Mason test suite on push and pull requests.

**Triggers:**
- Push to `master` or `main` branch
- Pull requests to `master` or `main` branch

**Platforms:**
- Ubuntu 22.04
- macOS 13

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
