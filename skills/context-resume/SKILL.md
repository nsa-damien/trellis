---
name: context-resume
description: Resume work from a previous session using a handoff document. Use when starting a new session and a handoff.md exists, when the user says "resume", "pick up where we left off", or "read handoff", or when continuing work started in a previous Claude Code session.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Instructions

### 1. Find Handoff Document

Look for the handoff file:

1. If `$ARGUMENTS` contains a file path, use that
2. Otherwise check for `handoff.md` in the project root
3. If not found, tell the user: "No handoff.md found. Use `/trellis:context-handoff` at the end of a session to generate one."

Read the handoff document fully before proceeding.

### 2. Validate Git State

Compare the handoff's Git State section against current reality:

```bash
git branch --show-current
git log --oneline -5
git status --short
```

Check for drift:

| Check | How | Match | Drift |
|-------|-----|-------|-------|
| Branch | Compare current branch to handoff's branch | On correct branch | "Handoff says `feat/X` but you're on `main`" |
| Last commit | Compare `git log -1 --format=%h` to handoff's last commit hash | Same commit | "N new commits since handoff" — show them |
| Uncommitted changes | Compare `git status --short` to handoff's uncommitted summary | Consistent | "Handoff expected uncommitted changes but tree is clean" (or vice versa) |

**If branch doesn't match**: Ask the user whether to switch (`git checkout <branch>`) or continue on the current branch.

**If new commits exist**: Show them with `git log --oneline <handoff-hash>..HEAD` so the user knows what changed.

### 3. Present Orientation

Display a compact summary:

```
RESUMING: <goal from handoff, one line>
BRANCH:   <current branch> <match/drift indicator>
LAST:     <last commit hash + message>

COMPLETED:
• <completed item 1>
• <completed item 2>

IN PROGRESS:
• <in-progress item — current state>

REMAINING:
• [ ] <next task>
• [ ] <task after that>
```

If the handoff has Decisions, Dead Ends, or Discoveries sections, include a brief note:

```
CONTEXT:
• <N> decisions documented (key: <most important one>)
• <N> dead ends to avoid
• <N> discoveries noted
```

### 4. Suggest First Action

Read the handoff's Resume Instructions section and present the specific first steps.

If drift was detected, prepend a recovery step:
- Branch mismatch: "First, switch to the correct branch"
- New commits: "Review the N new commits before continuing — they may affect your plan"
- Missing uncommitted changes: "Expected in-progress changes are gone — check if they were committed or lost"

### 5. Wait for User

Do not start working automatically. Present the orientation and wait for the user to confirm or redirect.

## Notes

- This is read-only — no modifications to files, git, or project state (except branch checkout if user approves)
- Pairs with `/trellis:context-handoff` which generates the handoff document
- If the handoff document is stale (>48 hours old based on the Generated timestamp), warn the user that significant drift is likely
