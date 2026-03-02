---
name: push
description: Commit, push, update PR. Use when user says "push", "PRに反映", "commit push", or wants to save and push work.
---

# Commit, Push, PR

When the user wants to commit and push (or similar phrasing), do the following without asking:

1. **Check status**: `git status`
2. **Stage**: `git add` (appropriate files, exclude outputs/ and other gitignored)
3. **Commit**: `git commit -m "..."` with a concise message describing the changes
4. **Push**: `git push`

If on a feature branch with a PR, the push updates the PR automatically.

**Commit message**: Use imperative, concise. Examples:
- `Add README sync rule`
- `Simplify CI to Docker only`
- `Fix locale warning in Docker`
