---
version: 1.0.0
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
3. If using beads, run `bd sync --from-main` to pull latest beads updates (if on ephemeral branch)
4. Check `bd list --status=in_progress` to see if any issues should be closed with `bd close <id>`
5. Update the CHANGELOG.md file for any changes that should be documented for a subsequent release:
   - New features, bug fixes, breaking changes, deprecations
   - Skip for minor typos, internal refactoring, or documentation-only changes
6. Stage all relevant changes with `git add`
7. Write a commit message that:
   - Uses a single concise subject line (50 chars or less if possible)
   - Follows conventional commit format when appropriate (feat:, fix:, refactor:, docs:, chore:, etc.)
   - Focuses on WHAT changed and WHY, not HOW
   - Does NOT include lengthy descriptions, bullet lists, or verbose explanations
   - Includes the standard co-authored-by footer:
     ```
     🤖 Generated with [Claude Code](https://claude.com/claude-code)
     ```
8. Commit the changes
9. Push to the current branch with `git push` (use `-u origin <branch>` if no upstream is set)
10. Do NOT create a pull request

## Important

- Keep the commit message short and meaningful
- If there are multiple unrelated changes, ask the user if they want separate commits or one combined commit
- Do not include files that look like secrets (.env, credentials, etc.) without asking
- NEVER use `--force` or `--force-with-lease` unless explicitly requested by the user
- Warn the user if they request a force push to main/master branches
