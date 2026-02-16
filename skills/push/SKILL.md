---
name: push
description: Commit and push current changes to the remote repository with changelog updates
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

Commit and push the current changes to the remote repository.

## Instructions

1. Run `git status` to see all staged and unstaged changes
2. Run `git diff --staged` and `git diff` to understand what changed
3. If beads is configured (`.beads/` directory exists and `bd` command available):
   - Run `bd sync --from-main` to pull latest beads updates (if not on main branch)
   - Run `bd list --status=in_progress` to see if any issues should be closed with `bd close <id>`
   - If `bd` commands fail, warn user but continue with git operations
4. Update the CHANGELOG.md file for any changes that should be documented for a subsequent release:
   - New features, bug fixes, breaking changes, deprecations
   - Skip for minor typos, internal refactoring, or documentation-only changes
5. Stage all relevant changes with `git add`
6. Write a commit message that:
   - Uses a single concise subject line (50 chars or less if possible)
   - Follows conventional commit format when appropriate (feat:, fix:, refactor:, docs:, chore:, etc.)
   - Focuses on WHAT changed and WHY, not HOW
7. Commit the changes
8. Push to the current branch with `git push` (use `-u origin <branch>` if no upstream is set)
9. Do NOT create a pull request

## Important

- Keep the commit message short and meaningful
- If there are multiple unrelated changes, ask the user if they want separate commits or one combined commit
- Do not include files that look like secrets (.env, credentials, etc.) without asking
- NEVER use `--force` or `--force-with-lease` unless explicitly requested by the user
- Warn the user if they request a force push to main/master branches
