---
name: release
description: Create release (tag + GitHub release) and update Homebrew tap. Use when user says "release", "/release", "リリース", "タグ打って", or wants to publish a new version.
---

# Release mov2mp4

When the user wants to release a new version (after merge), do the following.

**Prerequisites**: CI passed, PR merged to main. Run from mov2mp4 project root.

**Related repo**: [masa0221/homebrew-tap](https://github.com/masa0221/homebrew-tap) — this repo is distributed via Homebrew tap.

## 1. Create tag and push (mov2mp4)

```bash
git checkout main && git pull
git tag v0.2.0
git push origin v0.2.0
```

- Determine version (e.g. v0.1.0 → v0.2.0). Ask user if unclear.
- Optional: `gh release create v0.2.0 --generate-notes` for release notes

## 2. Create Homebrew tap PR

```bash
brew tap masa0221/tap
brew bump-formula-pr masa0221/tap mov2mp4
```

- `brew bump-formula-pr` updates formula url/sha256 and creates the PR
- Use `--version 0.2.0` if needed to specify version

## 3. Wait for CI

- homebrew-tap GitHub Actions (tests.yml) runs
- Wait until PR CI passes

## 4. Add pr-pull label

- Add `pr-pull` label to the created PR
- Bottle gets merged and pushed to main

## 5. Done

- `brew install masa0221/tap/mov2mp4` or `brew upgrade mov2mp4` becomes available

## Summary

1. Create tag → push
2. `brew bump-formula-pr masa0221/tap mov2mp4`
3. Wait for CI
4. Add `pr-pull` label to PR
