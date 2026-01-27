---
name: trellis.release
description: Create a release with changelog, release notes, and tagged GitHub release (auto-creates PR if needed)
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

Create a release with changelog, release notes, and tagged GitHub release. Automatically creates a PR if one doesn't exist.

## Instructions

### 1. Verify or Create PR
1. Run `git branch --show-current` to get current branch name
2. **If empty (detached HEAD state): STOP and inform user** they must checkout a branch first
3. **If on main/master: STOP and inform user** they must be on a feature branch to create a release
4. Run `gh pr view --json number,title,state,baseRefName` to check for an open PR
   - **If command fails with auth/network errors: STOP and inform user** of the connectivity issue
5. **If no PR exists or PR is not open**, create one:
   a. Check for uncommitted changes with `git status`
   b. If uncommitted changes exist, ask user if they want to commit them first
   c. If yes, stage and commit with a descriptive message (follow `/trellis.push` process)
   d. Push to remote: `git push -u origin $(git branch --show-current)`
      - **If push fails: STOP and inform user.** Cannot create PR without pushing to remote first.
   e. Create the PR:
      ```bash
      gh pr create --title "<title>" --body "$(cat <<'EOF'
      ## Summary
      <!-- Auto-generated PR for release -->

      ## Changes
      <!-- See commit history -->

      ## Test Plan
      <!-- How to test these changes -->

      ## Related Issues
      <!-- Link to any related beads issues or GitHub issues -->
      EOF
      )"
      ```
   f. **If PR creation fails: STOP and inform user.** The release cannot proceed without a valid PR.
   g. Inform user that PR was auto-created
6. Confirm the PR base branch (should be main/master)

### 2. Analyze Changes
1. Run `git status` and `git diff` to understand staged/unstaged changes
2. Run `git log main..HEAD --oneline` to see commits in this PR
3. Identify the type of changes (breaking, features, fixes) for semantic versioning

### 3. Determine Version
1. Check the current version from package.json, pyproject.toml, VERSION file, or latest git tag
2. Apply semantic versioning based on changes:
   - **MAJOR**: Breaking changes or incompatible API changes
   - **MINOR**: New features, backward compatible
   - **PATCH**: Bug fixes, backward compatible
3. Detect if this is a pre-release:
   - Check if version includes suffix: `-alpha`, `-beta`, `-rc`, or similar
   - If user input includes "alpha", "beta", "rc", treat as pre-release
   - Ask user if unsure
4. **Validate version**: Ensure new version is greater than current version using semver comparison
5. **Check for existing tag**: Run `git tag -l "v{{version}}"` to verify tag doesn't already exist
   - **If tag exists: STOP and inform user**: "Tag v{{version}} already exists. Choose a different version or delete the existing tag."
6. Confirm the new version with the user before proceeding

### 4. Update Documentation
1. Update CHANGELOG.md following Keep a Changelog format:
   - Add new version header with date: `## [X.Y.Z] - YYYY-MM-DD`
   - Categorize changes: Added, Changed, Deprecated, Removed, Fixed, Security
   - Keep entries concise and user-focused
   - **Validation**: After updating, verify the new version section exists in CHANGELOG.md
2. Create release notes:
   - **Check if `docs/release/` directory exists**, create it if needed: `mkdir -p docs/release`
   - Create release notes at `docs/release/v{{version}}.md`:
```markdown
   # Release v{{version}}

   **Release Date:** YYYY-MM-DD

   ## Highlights
   <!-- 2-3 sentence summary of the most important changes -->

   ## What's New
   <!-- Features added in this release -->

   ## Bug Fixes
   <!-- Issues resolved -->

   ## Breaking Changes
   <!-- If any, with migration guidance -->

   ## Upgrade Instructions
   <!-- Steps to upgrade from previous version -->
```
3. Update version in project files if applicable (package.json, pyproject.toml, etc.)

### 5. Commit & Push
1. Stage all changes: `git add -A`
2. Commit with message: `chore(release): v{{version}}`
3. Push to current branch: `git push`

### 6. Merge PR
1. **Store the current branch name** for cleanup: `FEATURE_BRANCH=$(git branch --show-current)`
2. Merge the existing PR: `gh pr merge --squash` (or `--merge` based on project convention)
3. If merge fails due to required approvals, **STOP and inform user**: "PR requires approval before release can continue. After approval, re-run the release command."
4. **Handle merge failure**: If merge fails for other reasons, **STOP and inform user** with the error. Do not proceed to tagging.

### 7. Tag & Create Release
1. Switch to main and pull: `git checkout main && git pull`
2. Create annotated tag: `git tag -a v{{version}} -m "Release v{{version}}"`
   - **Handle tag creation failure**: If this fails, tag might already exist remotely. Check with `git ls-remote --tags origin v{{version}}`
3. Push tag: `git push origin v{{version}}`
   - **Handle push failure**: If this fails, check if tag already exists on remote or if you have push permissions
4. Create GitHub release:
   - Determine if pre-release: check if version contains `-alpha`, `-beta`, or `-rc`
   - Run: `gh release create v{{version}} --title "v{{version}}" --notes-file docs/release/v{{version}}.md`
   - Add `--prerelease` flag if version contains alpha/beta/rc suffix
   - **Handle release creation failure**: If `gh release create` fails, check the error:
     - If release already exists: `gh release view v{{version}}` to see existing release
     - If notes file missing: Verify `docs/release/v{{version}}.md` exists
     - For other errors: Report to user and provide rollback instructions

### 8. Cleanup & Finalize
1. **Delete the feature branch**:
   - Local: `git branch -d $FEATURE_BRANCH` (if stored from step 6)
   - Remote: `gh pr view --json headRefName -q .headRefName | xargs -I {} git push origin --delete {}`
   - If branch deletion fails, it's non-critical, inform user but continue
2. Ensure main branch is checked out: `git checkout main`
3. Confirm release was created successfully: `gh release view v{{version}}`

## Error Recovery & Rollback

If the release process fails at any stage, follow these recovery steps:

### If failure occurs BEFORE merging PR (steps 1-5):
- No rollback needed - simply fix the issue and re-run the release command
- Uncommitted changes can be discarded: `git checkout -- .`

### If failure occurs AFTER merging PR but BEFORE tagging (step 6 complete, step 7 pending):
- PR is merged but no tag/release exists
- Simply re-run the release command, it will skip to tagging
- Or manually complete: create tag and release using steps 7-8

### If failure occurs AFTER tagging but BEFORE release creation (steps 7.1-7.3 complete):
- **Delete the tag**:
  - Local: `git tag -d v{{version}}`
  - Remote: `git push origin --delete v{{version}}`
- Fix the issue, then re-run the release command

### If failure occurs DURING release creation (step 7.4):
- Tag exists but release failed
- **Option 1**: Retry release creation: `gh release create v{{version}} --title "v{{version}}" --notes-file docs/release/v{{version}}.md`
- **Option 2**: Delete tag and start over (see above)

### Complete rollback (undo a published release):
**WARNING**: Only do this for serious issues. Deleting published releases can confuse users.
```bash
# 1. Delete the GitHub release
gh release delete v{{version}} --yes

# 2. Delete the tag
git tag -d v{{version}}
git push origin --delete v{{version}}

# 3. (Optional) Revert the merge commit on main
git checkout main
git revert -m 1 HEAD  # Reverts the most recent merge
git push origin main
```

## Important

- **Auto-creates PR if needed** — no need to run `/trellis.pr` first
- **Always confirm version number** with user before making changes
- If PR requires approval, stop and allow user to get approval, then re-run release command
- Do not include secrets or credentials in release notes
- Pre-release versions (alpha/beta/rc) are automatically detected and marked with `--prerelease` flag
- Version validation prevents accidentally creating duplicate or lower versions
- All error conditions have specific handling and recovery instructions
