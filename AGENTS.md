# movie-converter Agent Guide

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
1. Create branch: `git checkout -b feature/xxx` or `fix/xxx`
2. Implement changes
3. Test locally (e.g. `./convert.sh tests/data`, Docker)
4. Commit and push
5. Create PR: `gh pr create`
6. CI runs on PR (Docker build + convert test)

## Quick: Commit & Push
Use skill `commit-push-pr` or say "commit push" / "PRに反映" to commit, push, and update PR without repeating the request.
