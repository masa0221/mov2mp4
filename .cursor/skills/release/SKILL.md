---
name: release
description: Create release (tag + Homebrew tap). Use when user says "release", "/release", "リリース", "タグ打って", or wants to publish a new version.
---

# Release mov2mp4

When the user wants to release a new version, do the following.

**Upstream**: Run earlier steps first if needed:

- Uncommitted changes or no open PR → run `pr` skill, then continue
- Open PR not merged → run `merge` skill (wait for CI, merge), then continue
- Only then run the release flow below.

**Related repo**: [masa0221/homebrew-tap](https://github.com/masa0221/homebrew-tap)

## Release flow

### 1. Create tag

```bash
git checkout main && git pull
git tag v0.1.1
git push origin v0.1.1
```

- Determine version (e.g. v0.1.0 → v0.1.1). Ask user if unclear.

### 2. Create Homebrew tap PR (gh + curl only)

Use gh and curl. Do not use brew bump-formula-pr (requires `HOMEBREW_GITHUB_API_TOKEN`).

```bash
V=v0.1.1
curl -sL "https://github.com/masa0221/mov2mp4/archive/refs/tags/${V}.tar.gz" -o /tmp/mov2mp4.tar.gz
SHA=$(shasum -a 256 /tmp/mov2mp4.tar.gz | cut -d' ' -f1)
gh repo clone masa0221/homebrew-tap /tmp/homebrew-tap
cd /tmp/homebrew-tap && git checkout -b mov2mp4-${V#v}
sed -i.bak "s|/v[0-9.]*\\.tar\\.gz|/${V}.tar.gz|" Formula/mov2mp4.rb
sed -i.bak "s|sha256 \"[^\"]*\"|sha256 \"${SHA}\"|" Formula/mov2mp4.rb
rm -f Formula/mov2mp4.rb.bak
git add Formula/mov2mp4.rb && git commit -m "mov2mp4 ${V}"
git push -u origin mov2mp4-${V#v}
gh pr create --title "mov2mp4 ${V}" --body "Bump mov2mp4 to ${V}"
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
| Homebrew PR (gh + curl) | Each release |
| Wait for CI | Each release |
| pr-pull label | Each release |
