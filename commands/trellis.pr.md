---
description: Create a pull request for the current branch
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).


Create a pull request for the current branch.

## Instructions

### 1. Verify Branch State
1. Run `git branch --show-current` to get current branch name
2. **If on main/master: STOP and inform user** they must be on a feature branch to create a PR
3. Run `gh pr view --json number,state 2>/dev/null` to check if a PR already exists
4. **If PR already exists and is open: STOP and inform user** with the PR URL

### 2. Check for Uncommitted Changes
1. Run `git status` to see all staged and unstaged changes
2. Run `git diff --staged` and `git diff` to understand what changed
3. If there are uncommitted changes:
   - Ask user if they want to commit them before creating the PR
   - If yes, follow the commit process from `/trellis.push`
   - If no, warn that uncommitted changes won't be in the PR

### 3. Sync Beads (if configured)
1. If beads is configured (`.beads/` directory exists and `bd` command available):
   - Run `bd sync --from-main` to pull latest beads updates
   - Run `bd list --status=in_progress` to see related issues
   - If `bd` commands fail, warn user but continue

### 4. Update Changelog
1. Run `git log main..HEAD --oneline` to see commits in this branch
2. Update CHANGELOG.md under the `## [Unreleased]` section:
   - Add entries for new features, bug fixes, breaking changes
   - Skip for minor typos, internal refactoring, or documentation-only changes
   - Categorize: Added, Changed, Deprecated, Removed, Fixed, Security
3. If CHANGELOG.md was updated, commit the change

### 5. Push to Remote
1. Check if branch has an upstream: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
2. If no upstream, push with: `git push -u origin $(git branch --show-current)`
3. If upstream exists, push with: `git push`
4. **If push fails: STOP and inform user** with the error

### 6. Create Pull Request
1. Analyze the commits and changes to draft a PR description:
   - Run `git log main..HEAD --oneline` for commit summary
   - Run `git diff main..HEAD --stat` for files changed
2. Create the PR:
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<!-- 1-3 bullet points describing the changes -->

## Changes
<!-- List of specific changes made -->

## Test Plan
<!-- How to test these changes -->

## Related Issues
<!-- Link to any related beads issues or GitHub issues -->
EOF
)"
```
3. Use a concise, descriptive title following conventional commit style when appropriate
4. If user provided arguments, incorporate them into the title or description

### 7. Report Success
1. Run `gh pr view --json url -q .url` to get the PR URL
2. Display the PR URL to the user
3. Inform user they can now:
   - Request reviews
   - Run `/trellis.release` when ready to merge and release

## Important

- **Must be on a feature branch** — will not create PR from main/master
- **One PR per branch** — will not create duplicate PRs
- Keep PR titles short and meaningful (50 chars or less if possible)
- Do not include files that look like secrets (.env, credentials, etc.) without asking
- If there are multiple unrelated changes, suggest splitting into separate PRs
- NEVER use `--force` push unless explicitly requested by the user
