# mov2mp4 Agent Guide

Context for AI agents working on this project.

## Project Overview

Shell script that converts .mov to MP4. Safe mode (Vrew-compatible) and fast mode.

## README

When modifying README.md, also update README.ja.md with the same content (translated to Japanese).

## Key Conventions

- **Output**: Always `outputs/` (gitignored)
- **Language**: English in scripts
- **Docker**: No wrappers, use docker commands directly
- **Tests**: `tests/data/` has both English and Japanese filenames

## When Adding Features

- Prefer `outputs/` for any generated output
- Add command checks at script start if new dependencies
- Use options (e.g. `-x`) not env vars for configuration
- Keep root minimal; put test-related stuff under `tests/`

## When Testing

- Output to `outputs/`
- Docker: `-v "$(pwd)/tests/data:/input" -v "$(pwd)/outputs:/output"`

## Development Workflow (do without being asked)

**When starting any fix or feature task**: First sync main, then create a branch. Do not work directly on main.

1. **Start from latest main**: `git checkout main && git pull` — always sync before creating a branch
2. **Create branch**: `git checkout -b feature/xxx` or `fix/xxx`
3. Implement changes
4. Test locally (e.g. `./tests/run-tests.sh`, Docker)
5. **Before commit**: Run `npx markdownlint-cli2 "**/*.md"` and fix issues (e.g. MD022: blank lines around headings)
6. Commit, push, create PR (use `/pr` skill — never push directly to main)
7. CI runs on PR (Docker build + convert test)
8. **After merge**: Create release (tag + homebrew-tap update) — use `/release` skill

## Quick: Commit & PR

Use skill `pr` or say "/pr" / "push" / "PRに反映" to create branch, commit, push, and open PR. **Never push directly to main.**

## Quick: Merge PR

Use skill `merge` or say "/merge" / "PRをマージ" to merge the current PR (squash), sync main, and delete the branch.

## Quick: Release (after merge)

Use skill `release` or say "/release" / "リリース" / "タグ打って" to create tag and update Homebrew tap.

### Release steps (reference)

This repo is distributed via [masa0221/homebrew-tap](https://github.com/masa0221/homebrew-tap).

1. Create version tag and push (e.g. v0.1.1)
2. Run `brew tap masa0221/tap` → `brew bump-formula-pr masa0221/tap mov2mp4`
3. Wait for PR CI to pass
4. Add `pr-pull` label to PR (tap bottle gets merged)
5. Done. `brew install masa0221/tap/mov2mp4` becomes available
