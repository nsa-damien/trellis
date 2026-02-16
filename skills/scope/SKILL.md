---
name: scope
description: Start a new scope of work — creates branch, implements autonomously, pushes, and creates PR
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Instructions

### 1. Parse Intent

Read the natural language description from `$ARGUMENTS`. This description defines the entire scope of work.

If `$ARGUMENTS` is empty, ask the user: "What would you like to work on? Describe the feature, fix, or change."

### 2. Detect Existing Branch

1. Run `git branch --show-current` to get the current branch name
2. **If on main or master**: Proceed to step 3 (create new branch)
3. **If on a feature branch** (any non-main/master branch):
   - Inform the user: "You're on branch `<branch-name>`. Start a new scope (creates new branch from main) or add work to this branch?"
   - **If new scope**: Run `git checkout main && git pull` then proceed to step 3
   - **If add to current branch**: Skip branch creation, proceed directly to step 5

### 3. Create Branch

1. **Determine scope type** by analyzing the description for keywords:

   | Type | Keywords | Branch prefix |
   |------|----------|---------------|
   | Bug fix | fix, bug, broken, error, crash, issue, wrong, failing | `fix/` |
   | Refactor | refactor, cleanup, reorganize, simplify, restructure | `refactor/` |
   | Chore | chore, update deps, ci, config, docs, lint, format, bump | `chore/` |
   | Feature | *(default — anything not matching above)* | `feat/` |

   Keyword matching is case-insensitive. If multiple types match, prefer the first match in order: fix, refactor, chore, feat.

2. **Generate short name**: Extract 2-4 key words from the description, convert to kebab-case. Drop filler words (the, a, an, for, to, and, of, in, on, with).
   - "add user authentication" -> `feat/user-authentication`
   - "fix login timeout error" -> `fix/login-timeout`
   - "refactor database connection pooling" -> `refactor/db-connection-pooling`
   - "update CI configuration" -> `chore/update-ci-config`

3. **Create and checkout the branch**:
   ```bash
   git checkout -b <type>/<short-name>
   ```
   If branch creation fails (e.g., branch already exists), append a numeric suffix: `<type>/<short-name>-2`

### 4. Beads Integration (Optional)

1. Check if the `bd` command is available: `command -v bd`
2. **If available**:
   - Map scope type to beads issue type: feature -> `feature`, fix -> `bug`, refactor -> `task`, chore -> `task`
   - Create a tracking issue:
     ```bash
     bd create --title="<description>" --type=<type> --priority=2
     ```
   - Store the returned issue ID for reference in the PR description
   - If `bd create` fails, warn but continue without beads tracking
3. **If not available**: Continue without beads. Do not prompt the user about this.

### 5. Propose Approach

Analyze the codebase and the description to formulate an implementation approach:

1. Read relevant files to understand the current state of the code
2. Identify which files will likely need to be created or modified
3. Present a concise approach summary to the user:

   ```
   SCOPE: <type>/<short-name>
   BRANCH: <branch-name>
   BEADS: <issue-id> (or "not tracked" if beads unavailable)

   APPROACH:
   - <bullet 1: what will be done>
   - <bullet 2: key files affected>
   - <bullet 3: any notable decisions>

   Proceed? [yes/no]
   ```

4. **Wait for user confirmation.** This is the ONLY human interaction point. After approval, everything runs autonomously.
5. If the user says no or requests changes, revise the approach and re-present.

### 6. Invoke Implement

After user approval, invoke the implement skill to execute the work autonomously:

```
Use the Skill tool to invoke: /trellis:implement <description>
```

Pass the full description as context so implement understands the scope of work.

**If the Skill tool invocation fails**, fall back to direct implementation:
- Execute the work directly based on the approved approach
- Commit changes incrementally with descriptive messages
- Follow conventional commit format: `<type>(scope): description`

### 7. Push and Create PR

After implementation completes:

1. **Ensure all changes are committed**:
   - Run `git status` to check for uncommitted changes
   - If uncommitted changes exist, stage and commit them:
     ```bash
     git add -A
     git commit -m "<type>(<scope>): <summary of remaining changes>"
     ```

2. **Push to remote**:
   ```bash
   git push -u origin $(git branch --show-current)
   ```
   If push fails, report the error and stop.

3. **Create the PR**:
   - Analyze all commits on the branch: `git log main..HEAD --oneline` (use `master` if `main` doesn't exist)
   - Analyze files changed: `git diff main..HEAD --stat`
   - Create the PR:
     ```bash
     gh pr create --title "<concise title>" --body "$(cat <<'EOF'
     ## Summary
     <1-3 bullet points describing what this scope accomplishes>

     ## Changes
     <list of specific changes made, grouped by area>

     ## Test Plan
     <how to verify the changes work correctly>

     ## Related Issues
     <beads issue ID if created, or "N/A">
     EOF
     )"
     ```
   - Use a concise title (under 70 characters) following conventional commit style
   - If PR creation fails, report the error but do not retry automatically

### 8. Report Results

Display a completion summary:

```
SCOPE COMPLETE: <type>/<short-name>

Branch: <branch-name>
PR: <pr-url>
Beads: <issue-id> (or "not tracked")
Commits: <count>
Files changed: <count>

Next: Run /trellis:release when ready to merge and publish.
```

## Notes

- Scope is the PRIMARY entry point for all new work in Trellis
- The two-command lifecycle is: `/trellis:scope` (branch + build + verify + PR) then `/trellis:release` (merge + tag + publish)
- Only ONE user confirmation is required (step 5). Everything before it is automatic setup; everything after it is autonomous execution.
- If the user provides additional flags in `$ARGUMENTS`, pass them through to `/trellis:implement`
- Never force-push. Never push to main/master directly.
- If `gh` CLI is not available or not authenticated, warn the user and skip PR creation. The branch will still be pushed.
