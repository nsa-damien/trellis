---
description: Bidirectional synchronization between beads issue tracker and tasks.md - reconcile status, detect conflicts, and maintain consistency
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

2. **Verify integration exists**:
   - Check if `FEATURE_DIR/beads-mapping.json` exists
   - If NOT found:
     - Display: "No beads integration found. Run `/trellis.import` first to create the integration."
     - **STOP** execution
   - Load and validate the mapping file structure
   - Verify beads database is accessible: `bd info --json`

3. **Load current state from both sources**:

   **Step 3a: Load beads state**:
   ```bash
   # Get all issues for this feature
   bd list --json | filter by IDs in beads-mapping.json
   ```

   For each mapped task, capture:
   ```
   BeadsState {
     beads_id: string,
     status: "open" | "in_progress" | "closed",
     closed_at: datetime | null,
     close_reason: string | null,
     updated_at: datetime,
     notes: string | null
   }
   ```

   **Step 3b: Load tasks.md state**:
   - Read `FEATURE_DIR/tasks.md`
   - For each task line, parse:
   ```
   TasksState {
     task_id: string,           // e.g., "T001"
     is_completed: bool,        // [X] = true, [ ] = false
     line_number: int,
     raw_line: string,
     has_inline_beads_id: bool, // Has <!-- beads:xxx --> comment
     inline_beads_id: string | null
   }
   ```

   **Step 3c: Load mapping file**:
   ```
   Mapping {
     task_id: string,
     beads_id: string,
     phase: int,
     description: string,
     line_number: int  // From original import
   }
   ```

4. **Detect discrepancies**:

   Compare each mapped task across all three sources:

   | Scenario | Beads Status | tasks.md | Action Required |
   |----------|--------------|----------|-----------------|
   | A | closed | `[ ]` | Update tasks.md to `[X]` |
   | B | open | `[X]` | Close in beads OR reopen in tasks.md |
   | C | in_progress | `[ ]` | No action (expected state) |
   | D | in_progress | `[X]` | Conflict - task marked done but beads says WIP |
   | E | closed | `[X]` | In sync - no action |
   | F | open | `[ ]` | In sync - no action |

   **Additional discrepancies**:
   - **Orphaned beads issues**: In beads but not in mapping file
   - **Missing beads issues**: In mapping but deleted from beads
   - **New tasks.md entries**: In tasks.md but not in mapping (added after import)
   - **Line number drift**: Task moved to different line in tasks.md

   Build discrepancy report:
   ```
   Discrepancy {
     task_id: string,
     beads_id: string,
     type: "A" | "B" | "C" | "D" | "E" | "F" | "orphaned" | "missing" | "new" | "drift",
     beads_status: string,
     tasks_md_status: string,
     suggested_action: string,
     requires_user_input: bool
   }
   ```

5. **Display sync status report**:

   ```
   ═══════════════════════════════════════════════════════════
   TRELLIS SYNC STATUS: [FEATURE_NAME]
   ═══════════════════════════════════════════════════════════

   CURRENT STATE:
   ┌─────────────────┬───────┬───────────────┬─────────────┐
   │ Source          │ Total │ Completed     │ Pending     │
   ├─────────────────┼───────┼───────────────┼─────────────┤
   │ Beads           │ 32    │ 15 closed     │ 17 open     │
   │ tasks.md        │ 32    │ 12 [X]        │ 20 [ ]      │
   └─────────────────┴───────┴───────────────┴─────────────┘

   DISCREPANCIES FOUND: 5

   ┌────────┬─────────────────┬────────────────┬─────────────┬──────────────────────┐
   │ Task   │ Beads ID        │ Beads Status   │ tasks.md    │ Suggested Action     │
   ├────────┼─────────────────┼────────────────┼─────────────┼──────────────────────┤
   │ T006   │ proj-a1b2.2.3   │ closed         │ [ ]         │ Update tasks.md      │
   │ T007   │ proj-a1b2.2.4   │ closed         │ [ ]         │ Update tasks.md      │
   │ T008   │ proj-a1b2.2.5   │ closed         │ [ ]         │ Update tasks.md      │
   │ T012   │ proj-a1b2.3.2   │ open           │ [X]         │ CONFLICT - choose    │
   │ T015   │ proj-a1b2.3.5   │ in_progress    │ [X]         │ CONFLICT - choose    │
   └────────┴─────────────────┴────────────────┴─────────────┴──────────────────────┘

   SYNC ACTIONS:
   • Auto-sync (no conflict): 3 tasks
   • Requires resolution: 2 tasks

   IN SYNC: 27 tasks
   ═══════════════════════════════════════════════════════════
   ```

6. **Resolve discrepancies**:

   **Type A - Beads closed, tasks.md open** (Auto-resolvable):
   ```bash
   # No beads action needed
   # Update tasks.md: - [ ] T006 → - [X] T006
   ```
   Action: Update tasks.md checkbox to `[X]`

   **Type B - Beads open, tasks.md completed** (Conflict):
   - Prompt user: "T012 is marked complete in tasks.md but open in beads. Choose:"
     1. Close in beads (trust tasks.md)
     2. Reopen in tasks.md (trust beads)
     3. Skip (leave inconsistent)

   If user chooses (1):
   ```bash
   bd close [BEADS_ID] --reason "Synced from tasks.md - marked complete" --json
   ```

   If user chooses (2):
   - Update tasks.md: `- [X] T012` → `- [ ] T012`

   **Type D - Beads in_progress, tasks.md completed** (Conflict):
   - Prompt user: "T015 is marked complete in tasks.md but still in_progress in beads. Choose:"
     1. Close in beads (work is actually done)
     2. Reopen in tasks.md (work still ongoing)
     3. Skip

   **Orphaned beads issues**:
   - Report issues in beads not in mapping
   - Offer to: add to mapping, close as obsolete, or ignore

   **Missing beads issues**:
   - Report mapped tasks where beads issue is deleted/missing
   - Offer to: recreate in beads, remove from mapping, or ignore

   **New tasks.md entries**:
   - Report tasks in tasks.md not in mapping (added after `/trellis.import`)
   - Offer to: import to beads (like `/trellis.import` would), or ignore

7. **Execute sync operations**:

   **Dry-run mode** (`--dry-run`):
   - Display all planned changes without executing
   - Show exact commands that would run
   - Show exact file modifications that would occur

   **Auto mode** (`--auto`):
   - Automatically resolve Type A discrepancies (beads closed → update tasks.md)
   - Skip conflicts (Types B, D) - report them for manual resolution
   - No prompts for auto-resolvable items

   **Force modes**:
   - `--force-beads`: Beads is always authoritative - update tasks.md to match
   - `--force-tasks`: tasks.md is always authoritative - update beads to match
   - These resolve conflicts without prompting

   **Interactive mode** (default):
   - Auto-resolve non-conflicts
   - Prompt for each conflict
   - Summarize changes before applying

8. **Update tasks.md**:

   For each task requiring tasks.md update:

   ```python
   def update_tasks_md(feature_dir, updates):
       tasks_md_path = f"{feature_dir}/tasks.md"
       content = read_file(tasks_md_path)
       lines = content.split('\n')

       for update in updates:
           task_id = update['task_id']
           new_status = update['new_status']  # 'complete' or 'incomplete'

           for i, line in enumerate(lines):
               # Match task line by ID
               if re.match(rf'^- \[[ Xx]\] {task_id}\b', line):
                   if new_status == 'complete':
                       lines[i] = re.sub(r'^- \[ \]', '- [X]', line)
                   else:
                       lines[i] = re.sub(r'^- \[[Xx]\]', '- [ ]', line)
                   break

       write_file(tasks_md_path, '\n'.join(lines))
   ```

   **Preserve formatting**:
   - Maintain original line structure
   - Only modify the checkbox portion
   - Keep all markers ([P], [USn], etc.) intact

9. **Update beads**:

   For each task requiring beads update:

   ```bash
   # Close task (trust tasks.md)
   bd close [BEADS_ID] --reason "Synced from tasks.md" --json

   # Reopen task (if incorrectly marked complete in tasks.md)
   bd reopen [BEADS_ID] --reason "Reopened via sync - tasks.md corrected" --json

   # Update status
   bd update [BEADS_ID] --status open --json
   ```

10. **Update mapping file**:

    After sync, update `beads-mapping.json` with:
    - New `last_synced_at` timestamp
    - Updated line numbers if tasks moved
    - Any new task mappings (if new tasks were imported)
    - Removed mappings (if tasks were deleted)

    ```json
    {
      "version": "1.0",
      "created_at": "2025-12-27T10:00:00Z",
      "last_synced_at": "2025-12-27T15:30:00Z",
      "sync_history": [
        {
          "timestamp": "2025-12-27T15:30:00Z",
          "tasks_synced": 5,
          "conflicts_resolved": 2,
          "direction": "bidirectional"
        }
      ],
      // ... rest of mapping
    }
    ```

11. **Validate sync integrity**:

    After all updates:

    ```bash
    # Verify beads state
    bd list --json | filter by feature

    # Re-parse tasks.md
    # Compare again - should show 0 discrepancies
    ```

    If discrepancies remain:
    - Report failed sync operations
    - Suggest manual intervention

12. **Generate sync report**:

    ```
    ═══════════════════════════════════════════════════════════
    TRELLIS SYNC COMPLETE: [FEATURE_NAME]
    ═══════════════════════════════════════════════════════════

    CHANGES APPLIED:

    tasks.md updates (beads → tasks.md):
    ┌────────┬─────────────────────────────────────────┬────────────┐
    │ Task   │ Description                             │ Change     │
    ├────────┼─────────────────────────────────────────┼────────────┤
    │ T006   │ Setup database migrations               │ [ ] → [X]  │
    │ T007   │ Configure environment management        │ [ ] → [X]  │
    │ T008   │ Setup logging infrastructure            │ [ ] → [X]  │
    └────────┴─────────────────────────────────────────┴────────────┘

    Beads updates (tasks.md → beads):
    ┌────────┬─────────────────────────────────────────┬────────────┐
    │ Task   │ Description                             │ Change     │
    ├────────┼─────────────────────────────────────────┼────────────┤
    │ T012   │ Create User model                       │ → closed   │
    └────────┴─────────────────────────────────────────┴────────────┘

    Conflicts resolved:
    • T012: Closed in beads (user chose: trust tasks.md)
    • T015: Reopened in tasks.md (user chose: trust beads)

    FINAL STATE:
    ┌─────────────────┬───────┬───────────────┬─────────────┐
    │ Source          │ Total │ Completed     │ Pending     │
    ├─────────────────┼───────┼───────────────┼─────────────┤
    │ Beads           │ 32    │ 16 closed     │ 16 open     │
    │ tasks.md        │ 32    │ 16 [X]        │ 16 [ ]      │
    └─────────────────┴───────┴───────────────┴─────────────┘

    ✓ Sources are now in sync

    FILES MODIFIED:
    • FEATURE_DIR/tasks.md (3 checkboxes updated)
    • FEATURE_DIR/beads-mapping.json (sync timestamp updated)

    BEADS OPERATIONS:
    • 1 issue closed
    • Run `bd sync` to commit beads changes to git
    ═══════════════════════════════════════════════════════════
    ```

## Sync Modes

### Direction Modes

**`--beads-to-tasks`** (one-way):
- Only update tasks.md from beads state
- Never modify beads
- Safe for "beads is source of truth" workflows

**`--tasks-to-beads`** (one-way):
- Only update beads from tasks.md state
- Never modify tasks.md
- Safe for "tasks.md is source of truth" workflows

**`--bidirectional`** (default):
- Sync in both directions
- Resolve conflicts via prompts or force flags

### Conflict Resolution Modes

**`--interactive`** (default):
- Prompt for each conflict
- Show context and options
- Wait for user decision

**`--auto`**:
- Auto-resolve non-conflicts
- Skip conflicts (report for later)
- No prompts

**`--force-beads`**:
- Beads always wins conflicts
- Update tasks.md to match beads
- No prompts

**`--force-tasks`**:
- tasks.md always wins conflicts
- Update beads to match tasks.md
- No prompts

## User Arguments

- `--dry-run`: Show what would change without applying
- `--auto`: Auto-resolve non-conflicts, skip conflicts
- `--force-beads`: Beads is authoritative for all conflicts
- `--force-tasks`: tasks.md is authoritative for all conflicts
- `--beads-to-tasks`: One-way sync from beads to tasks.md only
- `--tasks-to-beads`: One-way sync from tasks.md to beads only
- `--verbose`: Show all operations in detail
- `--quiet`: Only show errors and final summary
- `--include-notes`: Append beads close_reason as comment in tasks.md
- `--repair-mapping`: Fix line number drift and orphaned mappings

## Advanced Operations

### Repair Mode (`--repair-mapping`)

Fixes mapping file issues:
1. Re-scans tasks.md to update line numbers
2. Identifies orphaned mappings (task deleted from tasks.md)
3. Identifies unmapped tasks (new tasks in tasks.md)
4. Rebuilds mapping integrity

```bash
/trellis.sync --repair-mapping --dry-run
```

### Include Notes (`--include-notes`)

Appends beads close_reason to tasks.md as HTML comment:

Before:
```markdown
- [X] T006 Setup database migrations
```

After:
```markdown
- [X] T006 Setup database migrations <!-- Completed: Migrations created for users, sessions, and audit tables -->
```

### Validate Only (`--validate`)

Check sync status without making any changes:

```bash
/trellis.sync --validate
```

Returns exit code:
- 0: In sync
- 1: Discrepancies found (shows report)
- 2: Mapping file issues

## Error Handling

**Beads unreachable**:
- Retry with `--no-daemon`
- If persistent, report error and skip beads operations
- Suggest: "Run `bd info` to check beads status"

**tasks.md parse errors**:
- Report specific line numbers
- Skip problematic lines
- Continue with valid tasks

**Mapping file corruption**:
- Detect JSON parse errors
- Offer to rebuild from beads state
- Backup corrupted file before repair

**Concurrent modification**:
- Detect if tasks.md changed during sync
- Re-read and merge if safe
- Abort and report if conflicts

## Integration with Git

After sync completes, remind user:

```
Remember to commit your changes:

   git add FEATURE_DIR/tasks.md FEATURE_DIR/beads-mapping.json
   git commit -m "Sync beads and tasks.md status"

   # Also sync beads to git:
   bd sync
```

Or with `--git-commit` flag, auto-commit:
```bash
/trellis.sync --git-commit -m "Sync task status"
```

## Notes

- Sync is idempotent - running multiple times produces same result
- Beads `in_progress` status is preserved (not synced to tasks.md checkbox)
- Phase-level epics are synced when all child tasks are complete
- The mapping file `last_synced_at` is updated even if no changes were needed
- For major refactoring of tasks.md, consider re-running `/trellis.import` with `--force`
