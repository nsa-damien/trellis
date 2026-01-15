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
2. **If empty (detached HEAD state): STOP and inform user** they must checkout a branch first
3. **If on main/master: STOP and inform user** they must be on a feature branch to create a PR
4. Run `gh pr view --json number,state,url` to check if a PR already exists
   - If command succeeds with state "OPEN": **STOP and inform user** with the PR URL
   - If command succeeds with state "CLOSED" (not merged): Ask user if they want to reopen the existing PR or create a new one
   - If command succeeds with state "MERGED": Warn user the branch was already merged; suggest creating a new branch
   - If command fails with exit code 1 (no PR): Continue to create one
   - **If command fails with other errors** (auth, network, rate limit): **STOP and inform user** of the connectivity/auth issue

### 2. Check for Uncommitted Changes
1. Run `git status` to see all staged and unstaged changes
2. If there are uncommitted changes:
   - Ask user if they want to commit them before creating the PR
   - If yes, follow the commit process from `/trellis.push` (includes changelog updates)
   - If no, warn that uncommitted changes won't be in the PR

### 3. Sync Beads (if configured)
1. If beads is configured (`.beads/` directory exists and `bd` command available):
   - Run `bd sync --from-main` to pull latest beads updates
   - Run `bd list --status=in_progress` to see related issues for the PR description
   - If `bd` commands fail with "not a beads repository": Continue without beads
   - If `bd` commands fail with "database locked" or "merge conflict": Warn user to run `bd sync` manually before merging

### 4. Push to Remote
1. Check if branch has an upstream: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
2. If no upstream, push with: `git push -u origin $(git branch --show-current)`
3. If upstream exists, push with: `git push`
4. **If push fails: STOP and inform user** with the error

### 5. Create Pull Request
1. Analyze the commits and changes to draft a PR description:
   - Run `git log main..HEAD --oneline` for commit summary (use `master` if `main` doesn't exist)
   - Run `git diff main..HEAD --stat` for files changed
   - If beads in-progress issues were found in step 3, include them in Related Issues
2. Determine if this should be a draft PR:
   - If user arguments include "draft" or "--draft", add `--draft` flag
   - Otherwise, create a regular PR
3. Create the PR:
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
)" [--draft]
```
4. Use a concise, descriptive title following conventional commit style when appropriate
5. If user provided arguments (other than "draft"), incorporate them into the title or description
6. **If PR creation fails: STOP and inform user** with the specific error message. Common failures:
   - "pull request already exists": Another PR was created between check and create
   - "required status check": Branch protection rules blocking PR creation
   - "permission denied": User lacks write access to repository

### 6. Report Success
1. Run `gh pr view --json url -q .url` to get the PR URL
   - If this fails, inform user: "PR created but URL retrieval failed. Run `gh pr view` to see the PR."
2. Display the PR URL to the user
3. Inform user they can now:
   - Request reviews
   - Run `/trellis.release` when ready to merge and release

## Important

- **Must be on a feature branch** — will not create PR from main/master
- **One PR per branch** — will not create duplicate PRs
- **Supports draft PRs** — add "draft" to arguments to create a draft PR
- Keep PR titles short and meaningful (50 chars or less if possible)
- Do not include files that look like secrets (.env, credentials, etc.) without asking
- If there are multiple unrelated changes, suggest splitting into separate PRs
- NEVER use `--force` or `--force-with-lease` push unless explicitly requested by the user
- Warn the user if they request a force push to main/master branches
