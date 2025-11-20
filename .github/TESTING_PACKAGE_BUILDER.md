# Testing the Package Builder Workflow

This guide explains how to test the package-builder workflow without publishing to S3.

## Overview

There are two workflows for building packages:

1. **`package-builder.yml`** - Production workflow that builds and publishes to S3
2. **`test-package-builder.yml`** - Test workflow for dry runs (no S3 upload)

## Quick Start: Test a Package Build

### Method 1: Using GitHub Actions UI (Recommended)

1. **Push your changes to GitHub**
   ```bash
   git add .
   git commit -m "Test package builder"
   git push origin master
   ```

2. **Go to GitHub Actions**
   - Navigate to your repository on GitHub
   - Click the **Actions** tab
   - Click **Test Package Builder (Dry Run)** in the left sidebar

3. **Run the workflow**
   - Click **Run workflow** button (right side)
   - Fill in the inputs:
     - **Package name**: `zlib` (or any existing package)
     - **Package version**: `1.2.8` (or any existing version)
     - **Platform**: Choose `linux`, `macos`, or `all`
   - Click **Run workflow**

4. **Monitor the build**
   - Click on the running workflow
   - Watch the build progress
   - Download artifacts if build succeeds

### Method 2: Using GitHub CLI

```bash
# Install GitHub CLI if needed
# brew install gh  (macOS)
# or https://cli.github.com/

# Test build a simple package (Linux only)
gh workflow run test-package-builder.yml \
  -f package_name=zlib \
  -f package_version=1.2.8 \
  -f platform=linux

# Test build on both platforms
gh workflow run test-package-builder.yml \
  -f package_name=variant \
  -f package_version=1.1.0 \
  -f platform=all

# Check workflow status
gh run list --workflow=test-package-builder.yml

# View logs of latest run
gh run view --log
```

## Testing Strategy

### 1. Test with Simple Packages First

Start with packages that are quick to build:

**Header-only packages (fastest):**
```bash
# These just copy headers, no compilation
variant 1.1.0
geometry 0.9.2
any 8fef1e9
```

**Small binary packages:**
```bash
# Quick to build from source
zlib 1.2.8
sqlite 3.8.8.1
libuv 0.11.29
```

**Large packages (for comprehensive testing):**
```bash
# Take longer but test complex builds
boost 1.75.0
llvm 11.0.0
cmake 3.21.2
```

### 2. Test Your New Packages

For the new packages you added:

**Test LLVM versions:**
```bash
# Test one LLVM version first
gh workflow run test-package-builder.yml \
  -f package_name=llvm \
  -f package_version=12.0.1 \
  -f platform=linux
```

**Test CMake versions:**
```bash
gh workflow run test-package-builder.yml \
  -f package_name=cmake \
  -f package_version=3.22.0 \
  -f platform=linux
```

**Test Boost versions:**
```bash
gh workflow run test-package-builder.yml \
  -f package_name=boost \
  -f package_version=1.76.0 \
  -f platform=linux
```

### 3. Update Checksums

New packages have placeholder `UPDATEME` checksums. To get the correct checksum:

```bash
# Download the source tarball locally
curl -LO <source-url-from-script.sh>

# Calculate the git hash
git hash-object <downloaded-file>

# Update the checksum in scripts/<package>/<version>/script.sh
```

Example for cmake 3.22.0:
```bash
# Download
cd /tmp
curl -LO https://github.com/Kitware/CMake/releases/download/v3.22.0/cmake-3.22.0.tar.gz

# Get hash
git hash-object cmake-3.22.0.tar.gz
# Output: 1234567890abcdef...

# Update scripts/cmake/3.22.0/script.sh
# Change "UPDATEME" to the actual hash
```

## What the Test Workflow Does

The `test-package-builder.yml` workflow:

1. ✅ **Verifies package exists** - Checks `scripts/{name}/{version}/` directory
2. ✅ **Checks script.sh** - Ensures build script is present
3. ✅ **Builds the package** - Runs `./mason build {name} {version}`
4. ✅ **Checks output** - Verifies package was installed correctly
5. ✅ **Uploads artifacts** - Saves build logs for debugging
6. ⚠️ **Skips S3 publish** - Doesn't upload to S3 (no AWS credentials needed)

## Local Testing (Before CI)

Test locally first to catch issues early:

```bash
# Test if package scripts exist
ls -la scripts/zlib/1.2.8/

# Test building locally
./mason build zlib 1.2.8

# Check where it was installed
./mason prefix zlib 1.2.8

# Verify the package works
ls -la $(./mason prefix zlib 1.2.8)
```

## Common Issues and Solutions

### Issue 1: Package directory not found

**Error:**
```
Error: Package scripts/mypackage/1.0.0 does not exist
```

**Solution:**
- Verify the directory exists: `ls scripts/mypackage/1.0.0/`
- Check spelling of package name and version
- Ensure you pushed the new package to GitHub

### Issue 2: Checksum mismatch

**Error:**
```
Error: hash mismatch abc123 (expected) != def456 (actual)
```

**Solution:**
- Download the source tarball
- Calculate correct hash: `git hash-object <tarball>`
- Update the checksum in `script.sh`

### Issue 3: Build timeout

**Error:**
```
Job exceeded maximum timeout of 30 minutes
```

**Solution:**
- Large packages (like LLVM) may timeout
- Test locally first
- Consider building on a faster platform
- For production, use the full workflow with longer timeout

### Issue 4: Missing dependencies

**Error:**
```
configure: error: required library not found
```

**Solution:**
- Check if package needs additional dependencies
- Update the build environment setup in workflow
- Some packages may need specific tools (cmake, ninja, etc.)

## Progression: From Test to Production

### Step 1: Test Build (No Publish)
```bash
# Use test workflow - builds but doesn't publish
gh workflow run test-package-builder.yml \
  -f package_name=zlib \
  -f package_version=1.2.8 \
  -f platform=linux
```

### Step 2: Configure AWS Credentials

If you want to actually publish packages:

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Step 3: Production Build and Publish
```bash
# Use production workflow - builds AND publishes to S3
gh workflow run package-builder.yml \
  -f package_name=zlib \
  -f package_version=1.2.8 \
  -f platform=linux
```

## Debugging Failed Builds

### View Logs

**Via GitHub UI:**
1. Go to Actions tab
2. Click the failed run
3. Click on the failed job
4. Expand failed steps

**Via GitHub CLI:**
```bash
gh run view --log
```

### Download Build Artifacts

If build fails, artifacts are automatically uploaded:

**Via GitHub UI:**
1. Go to failed run
2. Scroll to **Artifacts** section at bottom
3. Download the artifact
4. Extract and examine logs

**Via GitHub CLI:**
```bash
gh run download <run-id>
```

### Check Build Directory

Artifacts include:
- `mason_packages/.build/` - Build logs and source
- `mason_packages/.cache/` - Downloaded tarballs
- `mason_packages/*/` - Installed packages

## Example Test Scenarios

### Scenario 1: Test New LLVM Version

```bash
# 1. Test locally first
./mason build llvm 12.0.1

# 2. If local build works, test in CI
gh workflow run test-package-builder.yml \
  -f package_name=llvm \
  -f package_version=12.0.1 \
  -f platform=linux

# 3. Check for errors, fix if needed

# 4. Test on macOS
gh workflow run test-package-builder.yml \
  -f package_name=llvm \
  -f package_version=12.0.1 \
  -f platform=macos

# 5. If all tests pass, publish to S3
gh workflow run package-builder.yml \
  -f package_name=llvm \
  -f package_version=12.0.1 \
  -f platform=all
```

### Scenario 2: Quick Header-Only Package Test

```bash
# Header-only packages are fast to test
gh workflow run test-package-builder.yml \
  -f package_name=variant \
  -f package_version=1.1.0 \
  -f platform=all
```

### Scenario 3: Test All New CMake Versions

```bash
# Test each version
for version in 3.22.0 3.25.0 3.27.0 3.30.0 3.31.0; do
  echo "Testing cmake $version"
  gh workflow run test-package-builder.yml \
    -f package_name=cmake \
    -f package_version=$version \
    -f platform=linux
  sleep 10  # Wait between runs
done
```

## Best Practices

1. **Test locally first** - Catch errors early
2. **Start with Linux** - Usually faster and cheaper
3. **Test small packages first** - Verify workflow works
4. **Update checksums** - Replace `UPDATEME` before testing
5. **Check artifacts** - Always review build output
6. **Test incrementally** - One package/version at a time
7. **Document issues** - Note any problems for future reference

## Monitoring Builds

```bash
# Watch all workflow runs
gh run watch

# List recent runs
gh run list --limit 10

# View specific run
gh run view <run-id>

# Cancel running build
gh run cancel <run-id>
```

## Next Steps

Once testing is successful:

1. ✅ All builds complete without errors
2. ✅ Checksums are updated (no `UPDATEME`)
3. ✅ Both Linux and macOS builds work
4. 🚀 Ready for production publishing with AWS credentials

Happy testing! 🎉
