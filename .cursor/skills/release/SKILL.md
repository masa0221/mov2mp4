---
name: release
description: Create release (tag + GitHub release) and update Homebrew tap. Use when user says "release", "/release", "リリース", "タグ打って", or wants to publish a new version.
---

# Release mov2mp4

When the user wants to release a new version (after merge), do the following.

**Prerequisites**: CI passed, PR merged to main. Run from mov2mp4 project root.

## 1. Create tag and GitHub release (mov2mp4)

1. **Sync main**: `git checkout main && git pull`
2. **Determine version**: Next version (e.g. v0.1.0 → v0.2.0). Ask user if unclear.
3. **Create tag**: `git tag v0.2.0` (use the chosen version)
4. **Push tag**: `git push origin v0.2.0`
5. **Create release**: `gh release create v0.2.0 --generate-notes`
   - Or `gh release create v0.2.0 --notes "Release notes..."` for custom notes

## 2. Update Homebrew tap (masa0221/homebrew-tap)

1. **Clone or open homebrew-tap**:
   - If not present: `git clone https://github.com/masa0221/homebrew-tap.git ../homebrew-tap`
   - Or use existing path (sibling to mov2mp4, or `HOMEBREW_TAP_PATH`)

2. **Get tarball sha256**:
   ```bash
   curl -sL "https://github.com/masa0221/mov2mp4/archive/refs/tags/v0.2.0.tar.gz" | shasum -a 256 | awk '{print $1}'
   ```

3. **Update Formula/mov2mp4.rb**:
   - `url`: `"https://github.com/masa0221/mov2mp4/archive/refs/tags/v0.2.0.tar.gz"`
   - `sha256`: the value from step 2
   - `desc`: Update if needed (e.g. add MP3 mention)

4. **Commit and PR** (in homebrew-tap):
   ```bash
   cd ../homebrew-tap  # or $HOMEBREW_TAP_PATH
   git checkout main && git pull
   git checkout -b bump-mov2mp4-v0.2.0
   # (formula already updated)
   git add Formula/mov2mp4.rb
   git commit -m "Bump mov2mp4 to v0.2.0"
   git push -u origin HEAD
   gh pr create --fill
   ```

## Summary

- **mov2mp4**: tag vX.Y.Z → push → `gh release create`
- **homebrew-tap**: update url + sha256 → branch → commit → push → PR

**Install after merge**: `brew install masa0221/tap/mov2mp4` or `brew upgrade mov2mp4`
