---
name: release
description: Create release (tag + Homebrew tap). Use when user says "release", "/release", "リリース", "タグ打って", or wants to publish a new version.
---

# Release mov2mp4

When the user wants to release a new version (after merge), do the following.

**Related repo**: [masa0221/homebrew-tap](https://github.com/masa0221/homebrew-tap)

## Prerequisites (one-time)

```bash
cd $(brew --repository masa0221/tap)
git remote set-url origin git@github.com:masa0221/homebrew-tap.git
git fetch origin
```

## Release flow

### 1. Create tag

```bash
git checkout main && git pull
git tag v0.1.1
git push origin v0.1.1
```

- Determine version (e.g. v0.1.0 → v0.1.1). Ask user if unclear.

### 2. Create Homebrew tap PR

```bash
brew tap masa0221/tap
brew bump-formula-pr --no-fork masa0221/tap mov2mp4
```

### 3. Wait for CI

- homebrew-tap GitHub Actions runs
- Wait until PR CI passes

### 4. Add pr-pull label

- Add `pr-pull` label to the PR
- Automatically merged

## Summary

| Step | Frequency |
|------|-----------|
| Tag create + push | Each release |
| brew bump-formula-pr | Each release |
| Wait for CI | Each release |
| pr-pull label | Each release |

No extra tools or PAT. These 4 steps only.
