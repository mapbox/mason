# Migration Guide: Travis CI to GitHub Actions

This document describes the migration of Mason from Travis CI to GitHub Actions.

## What Changed

### CI Infrastructure

**Before (Travis CI):**
- Each package version had a `.travis.yml` file
- Builds triggered via Travis CI API
- Used `./mason trigger <package> <version>` command

**After (GitHub Actions):**
- Centralized workflows in `.github/workflows/`
- Builds triggered via GitHub Actions UI or API
- No per-package CI configuration needed

### Workflow Changes

#### Building and Publishing Packages

**Old Method (Travis CI):**
```bash
# Required MASON_TRAVIS_TOKEN environment variable
export MASON_TRAVIS_TOKEN="your-token"
./mason trigger <package-name> <package-version>
```

**New Method (GitHub Actions):**

**Option 1: Via GitHub UI**
1. Go to the Actions tab in your Mason fork
2. Select "Build and Publish Package"
3. Click "Run workflow"
4. Fill in:
   - Package name (e.g., `llvm`)
   - Package version (e.g., `17.0.6`)
   - Platform (`all`, `linux`, or `macos`)
5. Click "Run workflow"

**Option 2: Via GitHub CLI**
```bash
gh workflow run package-builder.yml \
  -f package_name=llvm \
  -f package_version=17.0.6 \
  -f platform=all
```

**Option 3: Via GitHub API**
```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/YOUR_ORG/mason/actions/workflows/package-builder.yml/dispatches \
  -d '{"ref":"master","inputs":{"package_name":"llvm","package_version":"17.0.6","platform":"all"}}'
```

### Configuration Requirements

#### AWS Credentials

GitHub Actions requires repository secrets to be configured:

1. Go to your repository Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

These are used to publish built packages to S3.

## Creating New Package Versions

### Before (Travis CI)

1. Create package directory: `scripts/{name}/{version}/`
2. Add `script.sh` with build instructions
3. Add `.travis.yml` with Travis configuration
4. Commit and push
5. Run `./mason trigger {name} {version}`

### After (GitHub Actions)

1. Create package directory: `scripts/{name}/{version}/`
2. Add `script.sh` with build instructions
3. Commit and push
4. Trigger GitHub Actions workflow (see methods above)

**No CI configuration file needed per package!**

## Package Version Updates in This Migration

### LLVM/Clang Toolchain

Added versions:
- LLVM 12.0.1
- LLVM 13.0.1
- LLVM 14.0.6
- LLVM 16.0.6
- LLVM 17.0.6

Each LLVM version includes:
- `llvm` - Full LLVM toolchain
- `clang++` - C++ compiler
- `clang-format` - Code formatter
- `clang-tidy` - Static analyzer
- `llvm-cov` - Code coverage tool

### CMake

Added versions:
- CMake 3.22.0
- CMake 3.25.0
- CMake 3.27.0
- CMake 3.30.0
- CMake 3.31.0

### Boost

Added versions:
- Boost 1.76.0
- Boost 1.78.0
- Boost 1.80.0
- Boost 1.82.0
- Boost 1.84.0
- Boost 1.86.0

**Note:** Boost download URLs updated from deprecated Bintray to JFrog Artifactory.

## Important Notes

### Checksums Need Updating

New package versions have placeholder checksums marked as `UPDATEME`. Before building:

1. Download the source tarball
2. Calculate its git hash: `git hash-object <tarball>`
3. Update the checksum in `script.sh`

Example for CMake 3.22.0:
```bash
cd /tmp
curl -LO https://github.com/Kitware/CMake/releases/download/v3.22.0/cmake-3.22.0.tar.gz
git hash-object cmake-3.22.0.tar.gz
# Update scripts/cmake/3.22.0/script.sh with the hash
```

### Boost URL Changes

Bintray service was discontinued. Boost now uses:
```
https://boostorg.jfrog.io/artifactory/main/release/${VERSION}/source/boost_${VERSION}.tar.bz2
```

Alternative mirror:
```
https://sourceforge.net/projects/boost/files/boost/${VERSION}/boost_${VERSION}.tar.bz2
```

### Testing Locally

Always test package builds locally before triggering CI:

```bash
./mason build <package-name> <package-version>
```

This helps catch issues early without consuming CI minutes.

## Troubleshooting

### Build Failures

GitHub Actions uploads build artifacts on failure:
1. Go to the failed workflow run
2. Scroll to "Artifacts" section
3. Download build logs for debugging

### Missing Secrets

If you see errors about AWS credentials:
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set in repository secrets
- Check that your AWS credentials have S3 write permissions for the Mason bucket

### Old `.travis.yml` References

All `.travis.yml` files have been removed. If you find references in documentation or scripts, they should be updated to reference GitHub Actions workflows.

## Benefits of GitHub Actions

1. **Better Integration**: Native GitHub integration, no external service
2. **Clearer Logs**: Better log viewing and artifact management
3. **Faster Feedback**: Generally faster job startup times
4. **More Platforms**: Easy to add additional platforms/versions
5. **Cost**: Free for public repositories

## Questions?

For issues with the migration or GitHub Actions workflows, please:
1. Check existing GitHub Issues
2. Review `.github/workflows/README.md` for workflow documentation
3. Open a new issue with details about your problem
