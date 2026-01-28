---
name: status
description: Project health and statistics overview - progress, blocked work, and sync status
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Verify beads is available**:
   - Check if `bd` command is available
   - Check if `.beads/beads.db` exists in the repository
   - If not initialized: "Beads not initialized. Run `bd init` first."

2. **Gather project statistics**:
   ```bash
   bd stats --json
   bd ready --json
   bd blocked --json
   bd list --status in_progress --json
   ```

3. **Check for Trellis integration**:
   - Look for `beads-mapping.json` files in common locations
   - If found, load feature-specific context

4. **Display comprehensive status**:

   ```
   ═══════════════════════════════════════════════════════════
   TRELLIS PROJECT STATUS
   ═══════════════════════════════════════════════════════════

   OVERALL PROGRESS:
   ┌─────────────────┬───────┬────────────────────────────────┐
   │ Status          │ Count │ Progress                       │
   ├─────────────────┼───────┼────────────────────────────────┤
   │ Open            │ 12    │ ████████████░░░░░░░░ 40%       │
   │ In Progress     │ 3     │ ███░░░░░░░░░░░░░░░░░ 10%       │
   │ Closed          │ 15    │ ███████████████░░░░░ 50%       │
   └─────────────────┴───────┴────────────────────────────────┘

   Total: 30 issues | Complete: 50%

   BY PRIORITY:
   ┌──────────┬───────┬────────┬─────────┬─────────┐
   │ Priority │ Open  │ In Prg │ Closed  │ Total   │
   ├──────────┼───────┼────────┼─────────┼─────────┤
   │ P0       │ 0     │ 0      │ 2       │ 2       │
   │ P1       │ 3     │ 2      │ 8       │ 13      │
   │ P2       │ 5     │ 1      │ 4       │ 10      │
   │ P3       │ 4     │ 0      │ 1       │ 5       │
   └──────────┴───────┴────────┴─────────┴─────────┘

   WORK STATUS:
   ┌─────────────────────────────────────────────────────────┐
   │ READY (5 tasks)                                         │
   ├─────────────────────────────────────────────────────────┤
   │ • proj-a1b2.1  [P1] Setup project structure             │
   │ • proj-a1b2.2  [P1] Initialize database schema          │
   │ • proj-a1b2.3  [P2] Create authentication module        │
   │ • proj-a1b2.4  [P2] Implement API endpoints             │
   │ • proj-a1b2.5  [P3] Add logging                         │
   └─────────────────────────────────────────────────────────┘

   ┌─────────────────────────────────────────────────────────┐
   │ IN PROGRESS (3 tasks)                                   │
   ├─────────────────────────────────────────────────────────┤
   │ • proj-a1b2.6  [P1] Database migrations                 │
   │ • proj-a1b2.7  [P1] User model implementation           │
   │ • proj-a1b2.8  [P2] API authentication                  │
   └─────────────────────────────────────────────────────────┘

   ┌─────────────────────────────────────────────────────────┐
   │ BLOCKED (4 tasks)                                       │
   ├─────────────────────────────────────────────────────────┤
   │ • proj-a1b2.9  blocked by: proj-a1b2.6, proj-a1b2.7     │
   │ • proj-a1b2.10 blocked by: proj-a1b2.8                  │
   │ • proj-a1b2.11 blocked by: proj-a1b2.9                  │
   │ • proj-a1b2.12 blocked by: proj-a1b2.10, proj-a1b2.11   │
   └─────────────────────────────────────────────────────────┘

   QUICK ACTIONS:
   • /trellis:ready       # Detailed view of ready work
   • /trellis:implement   # Start executing tasks
   • bd show <id>         # View specific issue
   • bd dep tree <id>     # View dependency tree
   ═══════════════════════════════════════════════════════════
   ```

5. **Show feature-specific status** (if beads-mapping.json found):

   ```
   FEATURE STATUS: [FEATURE_NAME]
   ┌──────────────────────┬──────────┬─────────────┬─────────┐
   │ Phase                │ Complete │ In Progress │ Pending │
   ├──────────────────────┼──────────┼─────────────┼─────────┤
   │ 1: Setup             │ 3/3      │ 0           │ 0       │
   │ 2: Foundational      │ 4/6      │ 2           │ 0       │
   │ 3: US1 - Login       │ 0/8      │ 0           │ 8       │
   │ 4: US2 - Dashboard   │ 0/10     │ 0           │ 10      │
   └──────────────────────┴──────────┴─────────────┴─────────┘

   SYNC STATUS:
   • Last synced: 2025-12-27 15:30:00
   • Beads ↔ tasks.md: In sync
   • Run `/trellis:sync --validate` to verify
   ```

6. **Health checks**:

   ```
   HEALTH CHECKS:
   ✓ Beads daemon running
   ✓ Database accessible
   ✓ No dependency cycles detected
   ✓ Git hooks installed
   ⚠ 2 issues have no assignee
   ⚠ 1 issue marked in_progress for >24h
   ```

## User Arguments

- `--json`: Output raw JSON statistics
- `--verbose`: Show all issues, not just summaries
- `--feature <name>`: Show status for specific feature only
- `--health`: Run health checks only
- `--quiet`: Show only counts, no tables

## Compact Mode

For quick status checks, use `--quiet`:

```
Trellis: 15/30 complete (50%) | Ready: 5 | In Progress: 3 | Blocked: 4
```

## Notes

- This command provides a read-only overview - no modifications are made
- For sync operations, use `/trellis:sync`
- For implementation, use `/trellis:implement`
- Health checks can identify issues before they become problems
