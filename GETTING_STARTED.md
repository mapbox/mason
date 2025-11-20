# Getting Started with Modernized Mason

## Quick Setup (One-time)

### 1. Merge Workflows to Main

The workflow files need to be on `main` to work properly:

```bash
# Create a PR with just the workflow changes
git checkout -b add-github-actions
git add .github/
git commit -m "Add GitHub Actions workflows"
git push origin add-github-actions

# Create and merge PR
gh pr create --title "Add GitHub Actions" --body "Migrate from Travis CI to GitHub Actions"
gh pr merge --auto --squash
```

### 2. Configure AWS Secrets (For Publishing)

Only needed if you want to publish packages to S3:

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

Skip this if you're only testing builds.

## Working with Packages

### Adding a New Package Version

```bash
# 1. Create feature branch
git checkout -b add-boost-1.86

# 2. Create package directory
mkdir -p scripts/boost/1.86.0

# 3. Add script.sh (copy from previous version)
cp scripts/boost/1.75.0/script.sh scripts/boost/1.86.0/
# ... edit script.sh with new version and checksum ...

# 4. Test locally
./mason build boost 1.86.0

# 5. Commit and push
git add scripts/boost/1.86.0/
git commit -m "Add Boost 1.86.0"
git push origin add-boost-1.86

# 6. Create PR
gh pr create --title "Add Boost 1.86.0"

# 7. CI runs automatically!
# The auto-test-packages workflow will:
# - Detect boost 1.86.0 was added
# - Build it on Linux and macOS
# - Show results on your PR
```

### CI Runs Automatically

Once you push, GitHub Actions automatically:

✅ **Smoke tests** - Always run (5-10 min)
✅ **Auto package test** - Builds changed packages (varies by package)
✅ **Results on PR** - See status checks directly

### After CI Passes

```bash
# Merge the PR
gh pr merge --squash

# Optionally publish to S3 (from main branch)
gh workflow run package-builder.yml \
  -f package_name=boost \
  -f package_version=1.86.0 \
  -f platform=all
```

## Package-Specific Guides

### Building Boost

✅ **Quick and easy** (~2-5 minutes)

```bash
./mason build boost 1.86.0
```

See: No special setup needed, checksums already configured.

### Building LLVM

⚠️ **Complex** (~30-80 minutes)

```bash
# Requires system compiler
export CUSTOM_CC=/usr/bin/clang
export CUSTOM_CXX=/usr/bin/clang++
./mason build llvm 17.0.6
```

See: [BUILD_LLVM_QUICK_START.md](BUILD_LLVM_QUICK_START.md) for details.

### Building CMake

⚠️ **Needs checksum update** (~10-15 minutes)

```bash
# First, update the checksum in scripts/cmake/3.22.0/script.sh
# Replace "UPDATEME" with actual hash (see MIGRATION.md)

./mason build cmake 3.22.0
```

## Workflow Types

### 1. Automatic (Recommended for most work)

**`auto-test-packages.yml`**
- Runs on every PR/push to feature branch
- Tests only changed packages
- No manual triggering needed

**`smoke-test.yml`**
- Runs on every PR/push
- Quick Mason CLI validation
- Always runs

### 2. Manual (For specific needs)

Must be triggered from `main` branch:

**`test-package-builder.yml`**
- Test builds without S3 publishing
- Good for one-off package testing

**`package-builder.yml`**
- Builds AND publishes to S3
- Use for production releases

**`test.yml`**
- Full comprehensive test suite
- Runs weekly or on-demand

**`debug-test.yml`**
- Environment debugging
- Use when troubleshooting CI issues

## Recommended Development Flow

### For New Package Versions

```
1. Create feature branch
   ↓
2. Add package scripts
   ↓
3. Test locally (./mason build ...)
   ↓
4. Push to GitHub
   ↓
5. Create PR → CI runs automatically ✨
   ↓
6. Fix issues if CI fails, push again
   ↓
7. Merge when green
   ↓
8. (Optional) Publish to S3 from main
```

### For Initial Workflow Setup

```
1. Create PR with .github/ directory
   ↓
2. Merge to main
   ↓
3. Workflows now available for all future PRs! ✨
```

## Common Questions

### Q: Can I test workflows before merging to main?

**A:** Partially.
- ✅ **Automatic workflows** (`auto-test-packages.yml`, `smoke-test.yml`) will run on your PR
- ❌ **Manual workflows** (`workflow_dispatch`) only work from main
- **Solution:** Merge workflows to main first, then they work everywhere

### Q: How do I test on feature branches?

**A:** Once workflows are on `main`:
- Automatic testing: Just push to feature branch → CI runs
- Manual testing: Can't trigger `workflow_dispatch` from feature branch
- **Workaround:** Use automatic workflows or test locally

### Q: Do I need to merge package changes to main to test them?

**A:** No!
- ✅ `auto-test-packages.yml` builds from your feature branch
- ✅ Tests run when you create/update PR
- ✅ No merge required for testing

### Q: What if I want to publish from a feature branch?

**A:** Not recommended, but possible:
- Merge workflows to main first
- Create PR with package changes
- After PR merges, trigger `package-builder.yml` from main

## File Checklist

### Required for Each Package

```
scripts/{package}/{version}/
├── script.sh         ✅ Required - Build instructions
├── base.sh          ⚠️ Optional - For packages like Boost
└── README.md        ⚠️ Optional - Documentation
```

### No Longer Needed

```
.travis.yml          ❌ Removed - Travis CI deprecated
circle.yml           ❌ Removed - Not used
```

## Getting Help

- **Workflow strategy**: [WORKFLOW_STRATEGY.md](.github/WORKFLOW_STRATEGY.md)
- **Testing guide**: [TESTING_PACKAGE_BUILDER.md](.github/TESTING_PACKAGE_BUILDER.md)
- **Quick reference**: [QUICK_START.md](.github/QUICK_START.md)
- **LLVM builds**: [BUILD_LLVM_QUICK_START.md](BUILD_LLVM_QUICK_START.md)
- **Migration from Travis**: [MIGRATION.md](MIGRATION.md)

## Summary

✨ **After merging workflows to main once:**
- All future package PRs get automatic CI testing
- No manual workflow triggers needed
- Tests run on feature branches
- Results show directly on PRs

Just push and let CI do the work! 🚀
