---
description: Execute implementation using beads for task tracking - wrapper around speckit.implement with LLM-aware dependency management
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Verify beads integration**:
   - Check if `FEATURE_DIR/beads-mapping.json` exists
   - If NOT found:
     - Display: "No beads integration found. Run `/trellis.import` first to import tasks, or use `/speckit.implement` for standard execution."
     - **STOP** execution
   - If found:
     - Load and parse the mapping file
     - Verify beads database is accessible: `bd info --json`
     - Verify root epic exists: `bd show [ROOT_EPIC_ID] --json`
     - If beads issues are missing/corrupted, offer to re-run `/trellis.import`

3. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     - Completed items: Lines matching `- [X]` or `- [x]`
     - Incomplete items: Lines matching `- [ ]`
   - Create a status table:

     ```text
     | Checklist   | Total | Completed | Incomplete | Status   |
     |-------------|-------|-----------|------------|----------|
     | ux.md       | 12    | 12        | 0          | ✓ PASS   |
     | test.md     | 8     | 5         | 3          | ✗ FAIL   |
     | security.md | 6     | 6         | 0          | ✓ PASS   |
     ```

   - **If any checklist is incomplete**:
     - Display the table with incomplete item counts
     - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 4

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 4

4. **Load implementation context**:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

5. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup
   - Follow the same detection and creation logic as standard speckit.implement:
     - .gitignore (if git repo)
     - .dockerignore (if Docker present)
     - .eslintignore, .prettierignore (if JS/TS tooling present)
     - .npmignore (if publishing)
     - .terraformignore, .helmignore (if infrastructure code present)
   - Apply technology-appropriate patterns from plan.md tech stack

6. **Get current beads state**:

   **Step 6a: Load mapping and beads status**:
   ```bash
   # Get all issues under the feature epic
   bd show [ROOT_EPIC_ID] --json

   # Get current ready work
   bd ready --json

   # Get blocked work for context
   bd blocked --json

   # Get overall statistics
   bd stats --json
   ```

   **Step 6b: Build execution state**:
   - Create a task status map from beads:
     ```
     TaskStatus {
       task_id: string,        // e.g., "T001"
       beads_id: string,       // e.g., "proj-a1b2.1.1"
       status: string,         // "open", "in_progress", "closed"
       is_ready: bool,         // True if in bd ready output
       is_blocked: bool,       // True if has open dependencies
       blocked_by: string[],   // List of blocking task IDs
       phase: int,             // Phase number from mapping
     }
     ```
   - Identify:
     - Completed tasks (status = closed)
     - In-progress tasks (status = in_progress)
     - Ready tasks (no blockers)
     - Blocked tasks (has open blockers)

   **Step 6c: Display current progress**:
   ```
   ═══════════════════════════════════════════════════════════
   TRELLIS IMPLEMENTATION STATUS: [FEATURE_NAME]
   ═══════════════════════════════════════════════════════════

   PROGRESS:
   ┌──────────────────────┬──────────┬─────────────┬─────────┐
   │ Phase                │ Complete │ In Progress │ Pending │
   ├──────────────────────┼──────────┼─────────────┼─────────┤
   │ 1: Setup             │ 3/3      │ 0           │ 0       │
   │ 2: Foundational      │ 2/6      │ 1           │ 3       │
   │ 3: US1 - Login       │ 0/8      │ 0           │ 8       │
   │ 4: US2 - Dashboard   │ 0/10     │ 0           │ 10      │
   └──────────────────────┴──────────┴─────────────┴─────────┘

   Overall: 5/27 tasks complete (18%)

   READY WORK (3 tasks):
   • T006 [P1] proj-a1b2.2.3: Setup database migrations
   • T007 [P1] proj-a1b2.2.4: Configure environment management

   BLOCKED (waiting on dependencies):
   • T008 blocked by: T006, T007
   • Phase 3 (US1) blocked by: Phase 2 completion
   ═══════════════════════════════════════════════════════════
   ```

7. **Beads-driven execution loop**:

   **IMPORTANT**: Unlike linear tasks.md execution, beads determines task order via dependencies. Execute tasks returned by `bd ready` in any order (they're unblocked).

   ```
   WHILE there are open tasks in the feature:

     # Get currently ready tasks
     ready_tasks = bd ready --json | filter by feature epic

     IF ready_tasks is empty AND open tasks exist:
       # All remaining tasks are blocked
       Display blocked status with bd blocked --json
       Ask user: "All remaining tasks are blocked. Review dependencies?"
       BREAK or wait for user guidance

     FOR each task in ready_tasks:

       # Step 7a: Claim the task
       bd update [BEADS_ID] --status in_progress --json
       Display: "▶ Starting: [TASK_ID] - [DESCRIPTION]"

       # Step 7b: Execute implementation
       - Read task details from mapping (file_path, description)
       - Load relevant context (contracts, data-model, etc.)
       - Implement the task following plan.md architecture
       - Run any relevant tests if TDD approach
       - Validate implementation meets task requirements

       # Step 7c: Handle task result
       IF task completed successfully:
         bd close [BEADS_ID] --reason "Implementation complete" --json
         Update tasks.md: Change `- [ ] [TASK_ID]` to `- [X] [TASK_ID]`
         Display: "✓ Completed: [TASK_ID]"

       ELSE IF task failed:
         # Keep status as in_progress for retry
         bd update [BEADS_ID] --notes "Failed: [ERROR_REASON]" --json
         Display: "✗ Failed: [TASK_ID] - [ERROR_REASON]"

         # For non-parallel tasks, halt and report
         IF task is sequential (not [P]):
           Display blocking error and suggest fixes
           Ask user: "Continue with other ready tasks, or stop?"
           IF stop: BREAK execution loop

         # For parallel tasks, continue with others
         ELSE:
           Log failure, continue with remaining ready tasks

       # Step 7d: Refresh ready queue
       # After each completion, new tasks may become unblocked
       ready_tasks = bd ready --json | filter by feature epic

     # Step 7e: Phase checkpoint
     IF all tasks in current phase are complete:
       Display phase completion message
       Verify phase checkpoint criteria (from tasks.md)
       bd close [PHASE_EPIC_ID] --reason "Phase complete" --json

   END WHILE
   ```

8. **Sync tasks.md after each task**:

   After completing each task, immediately sync to tasks.md:

   ```python
   # Pseudocode for sync
   def sync_task_completion(task_id, feature_dir):
       tasks_md_path = f"{feature_dir}/tasks.md"

       # Read current tasks.md
       content = read_file(tasks_md_path)

       # Find and update the specific task line
       # Match: - [ ] T001 ... or - [ ] T001 [P] ...
       pattern = rf"^- \[ \] {task_id}\b"
       replacement = f"- [X] {task_id}"

       updated_content = regex_replace(content, pattern, replacement)

       # Write back
       write_file(tasks_md_path, updated_content)
   ```

   **Conflict handling**:
   - If tasks.md was modified externally, detect and report conflicts
   - Beads is source of truth - tasks.md is updated to match beads state

9. **Progress tracking and reporting**:

   **After each task completion**:
   ```
   ✓ T006 Complete: Setup database migrations
     Phase 2: 3/6 complete | Overall: 6/27 (22%)
     Newly unblocked: T008, T009
   ```

   **Periodic status** (every 5 tasks or phase boundary):
   ```bash
   bd stats --json
   bd dep tree [ROOT_EPIC_ID]  # Show current hierarchy state
   ```

   **On blocking issues**:
   ```
   ⚠ Implementation blocked

   Blocked tasks:
   • T015 waiting on: T012 (in_progress), T014 (open)
   • T016 waiting on: T015

   Suggested actions:
   1. Complete T012 (currently in progress)
   2. Start T014 (ready to begin)
   ```

10. **Error handling and recovery**:

    **Beads connection issues**:
    - If `bd` commands fail, retry with `--no-daemon` flag
    - If persistent failure, fall back to tasks.md-only tracking with warning

    **Sync conflicts**:
    - If beads and tasks.md disagree on task status:
      - Beads is authoritative
      - Update tasks.md to match beads
      - Log the conflict for user review

    **Partial completion recovery**:
    - On restart, beads state is automatically loaded
    - In-progress tasks from previous session are identified
    - Offer to: resume in_progress task, mark it complete, or reset to open

    **Dependency cycle detection**:
    ```bash
    bd dep cycles --json
    ```
    - If cycles detected, report and suggest resolution

11. **Completion validation**:

    When all tasks show closed in beads:

    ```bash
    # Verify all issues closed
    bd list --status open --json | filter by feature epic

    # Should return empty - if not, report stragglers
    ```

    **Final sync**:
    - Ensure all tasks.md checkboxes match beads closed status
    - Close the root feature epic:
      ```bash
      bd close [ROOT_EPIC_ID] --reason "Feature implementation complete" --json
      ```
    - Run `bd sync` to commit all beads changes to git

12. **Generate manual test plan**:

    After implementation is complete, generate `FEATURE_DIR/test-plan.md`.

    **Step 12a: Gather context** from spec.md (user stories, acceptance criteria), plan.md (tech stack), contracts/ (API specs), data-model.md (entities), and the list of implemented files.

    **Step 12b: Generate test-plan.md** with these sections:

    ```markdown
    # Manual Test Plan: [FEATURE_NAME]

    **Generated**: [DATE] | **Feature Epic**: [ROOT_EPIC_ID] | **Status**: Complete

    ## Test Environment Setup
    - Prerequisites (software, accounts, env vars)
    - Setup steps with commands
    - Test user accounts and roles

    ## Manual Verification Checklist

    ### Phase 1: [PHASE_NAME]
    #### User Story: [US_ID] - [TITLE]
    **Test Case 1.1: [Scenario]**
    - [ ] Setup: [steps]
    - [ ] Action: [what to do]
    - [ ] Expected: [result]
    - [ ] Status: PASS / FAIL

    ## Feature Testing Scenarios

    ### Scenario 1: [Happy Path]
    **Steps**: [numbered steps with expected behavior]
    **Verification**: [checkboxes for specific validations]

    ## Notes
    [Space for tester observations]
    ```

    **Step 12c: Customize for implementation** - Use actual file paths, component names, API endpoints, field names, and setup commands from the implementation. Tailor to tech stack (curl examples for APIs, DevTools checks for web apps, CLI examples, etc.).

    **Display confirmation**:
    ```
    ✓ Manual test plan generated: [FEATURE_DIR]/test-plan.md
    Ready for QA validation.
    ```

13. **Completion report**:

    ```
    ═══════════════════════════════════════════════════════════
    TRELLIS IMPLEMENTATION COMPLETE: [FEATURE_NAME]
    ═══════════════════════════════════════════════════════════

    FINAL STATUS:
    ┌──────────────────────┬──────────┬────────────────────────┐
    │ Phase                │ Tasks    │ Status                 │
    ├──────────────────────┼──────────┼────────────────────────┤
    │ 1: Setup             │ 3/3      │ ✓ Complete             │
    │ 2: Foundational      │ 6/6      │ ✓ Complete             │
    │ 3: US1 - Login       │ 8/8      │ ✓ Complete             │
    │ 4: US2 - Dashboard   │ 10/10    │ ✓ Complete             │
    │ 5: Polish            │ 5/5      │ ✓ Complete             │
    └──────────────────────┴──────────┴────────────────────────┘

    SUMMARY:
    • Total tasks completed: 32
    • Total time tracked: [if beads time tracking enabled]
    • Parallel tasks executed: 12
    • Dependencies resolved: 28

    FILES MODIFIED:
    • tasks.md - All checkboxes synced
    • beads-mapping.json - Status updated
    • test-plan.md - Manual testing guide generated
    • [List of implementation files created/modified]

    BEADS CLEANUP:
    • Root epic closed: [ROOT_EPIC_ID]
    • All phase epics closed
    • Changes synced to git via `bd sync`

    VERIFICATION:
    • Follow test-plan.md for comprehensive manual testing
    • Run quickstart.md scenarios to validate implementation
    • Run test suite: [test command from plan.md]
    • Review implementation against spec.md user stories
    ═══════════════════════════════════════════════════════════
    ```

## Execution Modes

**Default mode**: Execute all ready tasks until completion or blockage

**Single-task mode** (`--task T001`):
- Execute only the specified task
- Useful for debugging or manual task selection

**Phase mode** (`--phase 3`):
- Execute only tasks in the specified phase
- Respects dependencies within that phase

**Dry-run mode** (`--dry-run`):
- Show what would be executed without making changes
- Displays task order, dependencies, and beads commands

**Continue mode** (`--continue`):
- Resume from last in_progress task
- Skip completed tasks automatically

## User Arguments

- `--dry-run`: Show execution plan without making changes
- `--task T001`: Execute only the specified task
- `--phase N`: Execute only tasks in phase N
- `--continue`: Resume from previous session
- `--no-sync`: Don't sync to tasks.md (beads only)
- `--verbose`: Show all bd commands as they execute
- `--force`: Continue past failures without prompting
- `--parallel-limit N`: Max parallel tasks to show/execute (default: all ready)

## Differences from Standard speckit.implement

| Aspect | speckit.implement | trellis.implement |
|--------|-------------------|-------------------------|
| Task order | Linear from tasks.md | Dependency-driven via `bd ready` |
| Status tracking | Checkbox in tasks.md | Beads database (synced to tasks.md) |
| Progress query | Parse markdown | `bd stats --json` |
| Blocked detection | Manual [P] markers | Automatic via `bd blocked` |
| Recovery | Re-read tasks.md | Beads state persists |
| Parallel work | Honor [P] markers | All ready tasks are parallel-safe |
| Dependencies | Implicit in order | Explicit and queryable |

## Notes

- This command requires `/trellis.import` to have been run first
- Beads is the source of truth; tasks.md is kept in sync for compatibility
- Run `bd sync` at end of session to ensure git commit of beads changes
- For standard execution without beads, use `/speckit.implement`
- The beads daemon handles concurrent access if multiple agents are working
