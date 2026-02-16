---
name: status
description: Project health overview — progress, ready work, branch state, and session recovery
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Instructions

### 1. Git Status (always available)

Gather git information:

```bash
git branch --show-current
git status --short
git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null
git log --oneline -5
```

Display:
- Current branch name
- Count of uncommitted changes (staged + unstaged + untracked)
- Ahead/behind remote (if tracking branch configured; if not, note "no upstream configured")
- Last 5 commit summaries

### 2. Beads Status (if available)

1. Check if `bd` command is available: `command -v bd`
2. Check if `.beads/` directory exists in the repository root

**If beads is available and initialized:**

Run these commands:
```bash
bd stats --json
bd ready --json
bd blocked --json
bd list --status=in_progress --json
```

Display overall progress:
```
BEADS PROGRESS:
┌─────────────────┬───────┬────────────────────────────────┐
│ Status          │ Count │ Progress                       │
├─────────────────┼───────┼────────────────────────────────┤
│ Open            │ [N]   │ [bar]                          │
│ In Progress     │ [N]   │ [bar]                          │
│ Closed          │ [N]   │ [bar]                          │
└─────────────────┴───────┴────────────────────────────────┘

Total: [N] issues | Complete: [N]%
```

Display ready work (unblocked tasks available for pickup):
```
READY WORK ([N] tasks):
• [id]  [priority] [title]
• [id]  [priority] [title]
...
```

Display in-progress work:
```
IN PROGRESS ([N] tasks):
• [id]  [priority] [title]
...
```

Display blocked work:
```
BLOCKED ([N] tasks):
• [id]  blocked by: [dependency-ids]
...
```

**If beads is NOT available or not initialized:**

Skip this entire section. Display a single line:
```
Beads: not configured (optional — run /trellis:init to set up)
```

### 3. Health Checks (always available)

Run health checks and report results:

| Check | How | Pass | Fail |
|-------|-----|------|------|
| Working tree clean | `git status --short` is empty | "Working tree clean" | "[N] uncommitted changes" |
| Remote tracking | `git rev-parse --abbrev-ref @{upstream}` succeeds | "Tracking [remote/branch]" | "No upstream configured" |
| Merge conflicts | `git diff --name-only --diff-filter=U` is empty | "No merge conflicts" | "[N] files with conflicts" |

If beads is available, also check:
| Check | How | Pass | Fail |
|-------|-----|------|------|
| Beads daemon | `bd sync --status` | "Daemon running" | "Daemon not running" |
| Dependency cycles | `bd dep cycles` is empty | "No dependency cycles" | "[N] cycles detected" |

Display results:
```
HEALTH:
[pass/fail] Working tree clean
[pass/fail] Remote tracking configured
[pass/fail] No merge conflicts
[pass/fail] Beads daemon running (if beads available)
[pass/fail] No dependency cycles (if beads available)
```

### 4. Quick Actions (contextual)

Suggest next steps based on the current state:

| Condition | Suggestion |
|-----------|------------|
| On main/master branch | `/trellis:scope "description"` to start new work |
| On feature branch with uncommitted changes | `/trellis:push` to commit and push |
| On feature branch, clean tree | `/trellis:scope` to continue working or start new scope |
| PR exists for current branch | `/trellis:release` to merge and publish |
| Beads has ready work | `/trellis:implement` to execute tasks |
| No CODEMAP.yaml exists | `/trellis:codemap` to map the codebase |

Display the top 2-3 most relevant suggestions:
```
NEXT STEPS:
• [suggestion with command]
• [suggestion with command]
```

## User Arguments

- `--json`: Output all gathered data as raw JSON (git status, beads stats, health checks)
- `--quiet`: One-line summary: `[branch] | [N] changes | [N]% complete | [N] ready`
- `--verbose`: Show all details including full commit messages, all beads issues, and extended health checks

## Notes

- This command is read-only; no modifications are made to files, git, or beads state
- Beads is entirely optional; the command is fully functional with git-only information
- If any individual command fails (e.g., `bd stats`), warn but continue with remaining checks
- To check for an existing PR, use `gh pr view --json number,title,state 2>/dev/null`
