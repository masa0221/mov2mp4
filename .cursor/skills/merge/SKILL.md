---
name: merge
description: Merge current PR and sync local main. Use when user says "merge", "/merge", "PRをマージ", or wants to merge the open PR.
---

# Merge PR

When the user wants to merge the current PR, do the following:

**Upstream**: If there are uncommitted changes or no open PR yet, run the `pr` skill first, then continue.

1. **Check branch**: Ensure you're on the feature branch with an open PR (or specify PR number)
2. **Wait for CI**: Ensure mov2mp4 repo CI has passed on the PR. Do not merge until green.
3. **Merge**: `gh pr merge --squash --delete-branch` (squash merge, delete remote branch after merge)
   - Or `gh pr merge <PR#> --squash --delete-branch` if merging a specific PR
4. **Sync local**: `git checkout main && git pull`
5. **Cleanup**: `git branch -d <feature-branch>` (delete local branch if it exists)

If the user prefers merge commit over squash, use `--merge` instead of `--squash`.

**Note**: Run from the feature branch, or specify the PR number to merge.

**After merge**: To release (tag + Homebrew), use the `release` skill or say "/release" / "リリース".
