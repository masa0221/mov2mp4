# movie-converter Agent Guide

Context for AI agents working on this project.

## Project Overview
Shell script that converts .mov to MP4. Safe mode (Vrew-compatible) and fast mode.

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
