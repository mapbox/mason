# GitHub Actions Workflow Strategy

## The GitHub Actions Branch Limitation

**Important:** GitHub Actions has a restriction on `workflow_dispatch` workflows:

> Manually triggered workflows (`workflow_dispatch`) can only be run from branches where the workflow YAML file exists.

This means:
- ❌ Can't trigger workflows from feature branches unless workflows exist there
- ✅ Can trigger from `main` branch once workflows are merged
- ✅ Workflows on `main` can checkout and build code from other branches

## Our Solution: Automatic Testing on PR/Push

Instead of manual triggers, we use **automatic path-based triggers**.

### Workflow: `auto-test-packages.yml`

**Triggers automatically when:**
- Pull requests that modify `scripts/**`
- Pushes to non-main branches that modify `scripts/**`

**What it does:**
1. Detects which package directories changed (e.g., `scripts/boost/1.86.0/`)
2. Extracts package name and version from path
3. Runs `./mason build` for each changed package
4. Tests on both Linux and macOS in parallel
5. Reports results on the PR

**Example:**
```
You push: scripts/boost/1.86.0/script.sh
         scripts/llvm/17.0.6/script.sh

CI automatically runs:
  - ./mason build boost 1.86.0  (Linux + macOS)
  - ./mason build llvm 17.0.6   (Linux + macOS)

Results show on your PR ✅ or ❌
```

## Complete Workflow Suite

### Automatic Workflows (No Manual Trigger Needed)

1. **`auto-test-packages.yml`** - NEW!
   - **Triggers:** PR or push to feature branch with `scripts/**` changes
   - **Purpose:** Auto-test changed packages
   - **Duration:** Varies (depends on packages changed)

2. **`smoke-test.yml`**
   - **Triggers:** Every push/PR
   - **Purpose:** Quick validation of Mason CLI
   - **Duration:** 5-10 minutes

### Manual Workflows (workflow_dispatch)

3. **`test-package-builder.yml`**
   - **Triggers:** Manual (from main branch only)
   - **Purpose:** Test specific package builds
   - **When:** After merging workflows, test packages manually

4. **`package-builder.yml`**
   - **Triggers:** Manual (from main branch only)
   - **Purpose:** Build and publish to S3
   - **When:** Publishing official releases

5. **`test.yml`**
   - **Triggers:** Manual or weekly schedule
   - **Purpose:** Full comprehensive test suite
   - **Duration:** 30-60 minutes

6. **`debug-test.yml`**
   - **Triggers:** Manual
   - **Purpose:** Debug CI environment issues

## Recommended Workflow

### For Package Development

```bash
# 1. Create feature branch
git checkout -b add-boost-1.86

# 2. Add/modify package
mkdir -p scripts/boost/1.86.0
# ... create script.sh ...

# 3. Commit and push
git add scripts/boost/1.86.0/
git commit -m "Add Boost 1.86.0"
git push origin add-boost-1.86

# 4. Create PR
gh pr create --title "Add Boost 1.86.0"

# 5. CI automatically runs!
# - smoke-test.yml runs immediately
# - auto-test-packages.yml detects boost/1.86.0 and builds it

# 6. See results on PR
# GitHub shows ✅ or ❌ for each check

# 7. Fix issues if needed, push again
# ... fix script.sh ...
git commit -am "Fix boost build"
git push

# CI runs again automatically

# 8. Merge when green
gh pr merge
```

### For Initial Setup (One-time)

```bash
# Merge workflow files to main first
git checkout -b add-workflows
git add .github/
git commit -m "Add GitHub Actions workflows"
git push origin add-workflows
gh pr create --title "Add GitHub Actions" --body "Migrate from Travis CI"
# Merge this PR

# Now workflows are available for all future PRs!
```

## Comparison: Manual vs Automatic

### Manual Trigger (workflow_dispatch)
- ✅ Full control over what/when to test
- ❌ Must be on main branch
- ❌ Requires manual triggering
- ❌ Easy to forget

### Automatic Trigger (on PR/push)
- ✅ Runs automatically on every change
- ✅ Works on feature branches
- ✅ Can't forget to test
- ✅ Shows results on PR
- ⚠️ May run unnecessary builds

## Our Strategy

**Use BOTH:**

1. **Automatic** (`auto-test-packages.yml`) - Default for all package changes
2. **Manual** (`test-package-builder.yml`) - For ad-hoc testing specific packages
3. **Smoke tests** - Always run on every PR
4. **Full tests** - Weekly comprehensive validation

This gives you:
- ✅ Fast PR feedback (automatic)
- ✅ Manual testing when needed
- ✅ Works on feature branches
- ✅ Comprehensive coverage

## Next Steps

1. Merge the workflows to main (one-time setup)
2. Future PRs automatically trigger package testing
3. Manual workflows available for specific testing needs