---
name: pr
description: Create branch, commit, push, and open PR. Use when user says "pr", "push", "PRに反映", "commit push", or wants to save and push work.
---

# Create PR (never push directly to main)

When the user wants to commit and push (or similar phrasing), do the following **without pushing directly to main**:

1. **Check status**: `git status`
2. **If on main branch**: Create a feature branch first:
   - `git checkout -b feature/update` (or `feature/<slug>` from commit message, e.g. "Rename X to Y" → `feature/rename-x-to-y`)
3. **Stage**: `git add` (appropriate files, exclude outputs/ and other gitignored)
4. **Commit**: `git commit -m "..."` with a concise message describing the changes
5. **Push**: `git push -u origin HEAD`
6. **Create PR**: `gh pr create` (or `gh pr create --fill` to use commit message as title/body)

If already on a feature branch with a PR, steps 2 and 6 are skipped; push updates the existing PR.

**Commit message**: Use imperative, concise. Examples:
- `Add README sync rule`
- `Simplify CI to Docker only`
- `Fix locale warning in Docker`

**Important**: Never `git push` to main. Always go through a branch and PR.
