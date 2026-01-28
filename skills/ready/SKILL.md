---
name: ready
description: Show issues ready to work - unblocked tasks with no pending dependencies
disable-model-invocation: true
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

2. **Get ready work from beads**:
   ```bash
   bd ready --json
   ```

3. **Display ready tasks**:

   ```
   ═══════════════════════════════════════════════════════════
   TRELLIS READY WORK
   ═══════════════════════════════════════════════════════════

   READY TASKS (5 items):
   ┌──────────────┬────┬─────────────────────────────────────────┐
   │ ID           │ P  │ Title                                   │
   ├──────────────┼────┼─────────────────────────────────────────┤
   │ proj-a1b2.1  │ P1 │ Setup project structure                 │
   │ proj-a1b2.2  │ P1 │ Initialize database schema              │
   │ proj-a1b2.3  │ P2 │ Create user authentication module       │
   │ proj-a1b2.4  │ P2 │ Implement API endpoints                 │
   │ proj-a1b2.5  │ P3 │ Add logging infrastructure              │
   └──────────────┴────┴─────────────────────────────────────────┘

   These tasks have no blockers and can be started immediately.

   QUICK ACTIONS:
   • bd update <id> --status in_progress  # Claim a task
   • bd show <id>                          # View task details
   • /trellis:implement                    # Auto-execute ready tasks
   ═══════════════════════════════════════════════════════════
   ```

4. **Handle empty state**:

   If no ready tasks:
   ```
   ═══════════════════════════════════════════════════════════
   TRELLIS READY WORK
   ═══════════════════════════════════════════════════════════

   No tasks are currently ready.

   POSSIBLE REASONS:
   • All tasks are complete
   • Remaining tasks are blocked by dependencies
   • No tasks have been imported yet

   NEXT STEPS:
   • bd blocked           # See what's blocking work
   • bd stats             # Check overall progress
   • /trellis:import      # Import tasks from tasks.md
   ═══════════════════════════════════════════════════════════
   ```

5. **Optional filters**:

   If user provides arguments:

   - `--priority P1` or `-p 1`: Show only tasks with specified priority
   - `--label US1`: Show only tasks with specified label
   - `--limit N`: Show only first N ready tasks
   - `--json`: Output raw JSON from beads

## User Arguments

- `--priority P1` / `-p 1`: Filter by priority (P0-P4 or 0-4)
- `--label <label>`: Filter by label (e.g., US1, test, parallel)
- `--limit N`: Show only first N results
- `--json`: Output raw JSON for scripting
- `--verbose`: Show full task descriptions and metadata

## Notes

- This is a quick status check - for full implementation, use `/trellis:implement`
- Ready tasks can be worked on in any order (they're all unblocked)
- Use `bd show <id>` to see task details including description and dependencies
