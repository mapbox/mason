# Quick Start Guide for Testing Mason Packages

## 🚀 Quick Reference

### Test a Package Build (Recommended First Step)

```bash
# Via GitHub Actions UI
1. Go to Actions → "Test Package Builder (Dry Run)"
2. Click "Run workflow"
3. Enter: package_name=zlib, package_version=1.2.8, platform=linux
4. Click "Run workflow"

# Via GitHub CLI
gh workflow run test-package-builder.yml \
  -f package_name=zlib \
  -f package_version=1.2.8 \
  -f platform=linux
```

### Test Locally

```bash
# Build a package
./mason build zlib 1.2.8

# Check where it's installed
./mason prefix zlib 1.2.8

# Verify installation
ls -la $(./mason prefix zlib 1.2.8)
```

## 📋 Testing Checklist for New Packages

- [ ] **1. Create package scripts** in `scripts/{name}/{version}/`
- [ ] **2. Test locally** with `./mason build {name} {version}`
- [ ] **3. Update checksums** (replace `UPDATEME` with actual git hash)
- [ ] **4. Test in CI** using `test-package-builder.yml`
- [ ] **5. Check artifacts** to verify build succeeded
- [ ] **6. Test on both platforms** (Linux and macOS)
- [ ] **7. Ready to publish** with `package-builder.yml`

## 🎯 Common Commands

### GitHub CLI Workflow Commands

```bash
# List all workflows
gh workflow list

# Run test build (no S3 publish)
gh workflow run test-package-builder.yml \
  -f package_name=<name> \
  -f package_version=<version> \
  -f platform=linux

# Run production build (publishes to S3)
gh workflow run package-builder.yml \
  -f package_name=<name> \
  -f package_version=<version> \
  -f platform=all

# Watch running workflows
gh run watch

# List recent runs
gh run list --limit 10

# View logs of latest run
gh run view --log

# Cancel a running workflow
gh run cancel <run-id>
```

### Local Mason Commands

```bash
# Check version
./mason --version

# Install a package (from S3 binary or build from source)
./mason install <package> <version>

# Build from source (skip binary download)
./mason build <package> <version>

# Get package installation path
./mason prefix <package> <version>

# Remove a package
./mason remove <package> <version>

# Show compiler flags
./mason cflags <package> <version>

# Show linker flags
./mason ldflags <package> <version>
```

## 🧪 Testing New Package Versions

### LLVM/Clang (takes ~30-60 min to build)

```bash
# Test one version
gh workflow run test-package-builder.yml \
  -f package_name=llvm \
  -f package_version=12.0.1 \
  -f platform=linux

# Test clang++
gh workflow run test-package-builder.yml \
  -f package_name=clang++ \
  -f package_version=12.0.1 \
  -f platform=linux
```

### CMake (takes ~10-15 min to build)

```bash
gh workflow run test-package-builder.yml \
  -f package_name=cmake \
  -f package_version=3.22.0 \
  -f platform=linux
```

### Boost (header-only, takes ~2-5 min)

```bash
gh workflow run test-package-builder.yml \
  -f package_name=boost \
  -f package_version=1.76.0 \
  -f platform=linux
```

## 🔍 Debugging Failed Builds

### View Logs

```bash
# Get run ID
gh run list --limit 5

# View logs
gh run view <run-id> --log

# Download artifacts
gh run download <run-id>
```

### Check Specific Issues

**Checksum mismatch:**
```bash
# Download source and calculate hash
curl -LO <source-url>
git hash-object <downloaded-file>
# Update script.sh with correct hash
```

**Missing dependencies:**
```bash
# Check build logs for missing libraries
# Update workflow to install dependencies
```

**Timeout:**
```bash
# Large packages may timeout
# Test locally first
# Consider splitting into smaller steps
```

## 📂 File Structure

```
mason/
├── .github/
│   ├── workflows/
│   │   ├── package-builder.yml        # Production: Build + Publish
│   │   ├── test-package-builder.yml   # Test: Build only (no publish)
│   │   ├── smoke-test.yml             # Quick CI tests
│   │   ├── test.yml                   # Full test suite
│   │   └── debug-test.yml             # Environment debugging
│   ├── TESTING_PACKAGE_BUILDER.md     # Detailed testing guide
│   └── QUICK_START.md                 # This file
├── scripts/
│   └── {package}/
│       └── {version}/
│           └── script.sh              # Build instructions
└── mason                              # Main CLI script
```

## ⚙️ AWS Configuration (For Publishing Only)

Only needed if you want to publish to S3:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

**Not needed for testing!** Use `test-package-builder.yml` to test without AWS credentials.

## 📊 Workflow Comparison

| Workflow | Builds? | Publishes? | Requires AWS? | Use Case |
|----------|---------|------------|---------------|----------|
| `test-package-builder.yml` | ✅ | ❌ | ❌ | Testing new packages |
| `package-builder.yml` | ✅ | ✅ | ✅ | Production releases |
| `smoke-test.yml` | ❌ | ❌ | ❌ | Quick CI validation |
| `test.yml` | ✅ | ❌ | ❌ | Comprehensive testing |
| `debug-test.yml` | ❌ | ❌ | ❌ | Debugging environment |

## 🎓 Learn More

- **Detailed testing guide**: [TESTING_PACKAGE_BUILDER.md](TESTING_PACKAGE_BUILDER.md)
- **Workflow documentation**: [workflows/README.md](workflows/README.md)
- **CI debugging**: [CI_DEBUGGING.md](CI_DEBUGGING.md)
- **Migration guide**: [../MIGRATION.md](../MIGRATION.md)
- **Mason README**: [../README.md](../README.md)

## 💡 Pro Tips

1. **Always test locally first** - Catches 90% of issues before CI
2. **Start with small packages** - zlib, variant are good for testing
3. **Use test-package-builder.yml first** - No S3 publishing, safer
4. **Check checksums** - Most common failure reason
5. **Read the logs** - They tell you exactly what went wrong
6. **Download artifacts** - Build logs saved for 7 days
7. **Test Linux first** - Usually faster and cheaper than macOS

## 🆘 Getting Help

If something doesn't work:

1. Check [CI_DEBUGGING.md](CI_DEBUGGING.md) for common issues
2. Run `debug-test.yml` to see environment details
3. Compare local vs CI behavior
4. Check GitHub Actions logs for specific errors
5. Verify package scripts exist and are correct

Happy building! 🏗️
