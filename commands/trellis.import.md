---
description: Import tasks.md into beads issue tracker for LLM-aware task execution with dependency management
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Verify beads installation**:
   - Check if `bd` command is available: `which bd || command -v bd`
   - Check if beads is initialized in the repo: Look for `.beads/beads.db`
   - If beads not initialized, prompt user: "Beads not initialized. Run `bd init` first, or should I initialize it now?"
   - If user agrees, run `bd init` with appropriate flags based on project setup

3. **Check for existing beads integration**:
   - If `FEATURE_DIR/beads-mapping.json` exists:
     - Display existing mapping summary
     - Ask: "Beads mapping already exists. Options: (1) Sync status only, (2) Re-import and overwrite, (3) Cancel"
     - If sync only: Jump to step 10 (sync phase)
     - If re-import: Continue with step 4
     - If cancel: Exit gracefully

4. **Load and parse tasks.md**:
   - Read `FEATURE_DIR/tasks.md`
   - Also read `FEATURE_DIR/plan.md` for feature name and context
   - Extract the following structure:

   **Feature metadata**:
   - Feature name from `# Tasks: [FEATURE NAME]` header
   - Any notes or context from the header section

   **Phase extraction** (each `## Phase N:` section):
   ```
   Phase {
     number: int,
     name: string,           // e.g., "Setup", "User Story 1 - Login"
     purpose: string,        // From **Purpose**: or **Goal**: line
     priority: string,       // From "(Priority: P1)" if present
     checkpoint: string,     // From **Checkpoint**: line if present
     is_user_story: bool,    // True if name contains "User Story"
     user_story_id: string,  // e.g., "US1" extracted from phase name
     tasks: Task[]
   }
   ```

   **Task extraction** (each `- [ ]` or `- [X]` line):
   ```
   Task {
     id: string,             // e.g., "T001", "T002"
     is_parallel: bool,      // True if [P] marker present
     user_story: string,     // e.g., "US1" from [US1] marker, empty if none
     description: string,    // Full task description
     file_path: string,      // Extracted file path (e.g., "src/models/user.py")
     is_completed: bool,     // True if [X], false if [ ]
     is_test: bool,          // True if in "Tests for" subsection
     raw_line: string        // Original line for sync purposes
   }
   ```

   **Dependency hints extraction**:
   - Parse "Dependencies & Execution Order" section
   - Extract phase dependencies
   - Extract user story dependencies
   - Note parallel execution examples

5. **Determine priority mapping**:
   - Map spec-kit priorities to beads priorities:
     - P1 (Critical) → beads priority 1 (High)
     - P2 (Medium) → beads priority 2 (Medium)
     - P3 (Low) → beads priority 3 (Low)
     - P4 (Backlog) → beads priority 4 (Backlog)
   - Setup/Foundational phases default to priority 1
   - Polish phase defaults to priority 3

6. **Create beads issue hierarchy**:

   **Step 6a: Create root feature epic**:
   ```bash
   bd create "[FEATURE_NAME] Implementation" -t epic -p 1 \
     -d "Feature implementation tracked via spec-kit. Source: FEATURE_DIR/tasks.md" \
     --json
   ```
   - Capture returned ID as `ROOT_EPIC_ID`

   **Step 6b: Create phase epics as children**:
   For each phase in order:
   ```bash
   bd create "Phase [N]: [PHASE_NAME]" -t epic -p [PRIORITY] \
     -d "[PURPOSE]\n\nCheckpoint: [CHECKPOINT]" \
     --json
   ```
   - Phase epics automatically get hierarchical IDs (e.g., `ROOT_EPIC_ID.1`, `.2`, etc.)
   - Store mapping: `phase_number → beads_id`

   **Step 6c: Create task issues under each phase**:
   For each task in each phase:
   ```bash
   bd create "[TASK_ID] [DESCRIPTION]" -t task -p [PRIORITY] \
     -d "File: [FILE_PATH]\n\nSource: tasks.md line [LINE_NUM]" \
     --json
   ```
   - Tasks get hierarchical IDs under their phase (e.g., `ROOT_EPIC_ID.1.1`, `.1.2`)
   - Store mapping: `task_id → beads_id`

   **Rate limiting**: Pause briefly between creates if creating many issues to avoid overwhelming the daemon.

7. **Create dependencies**:

   **Step 7a: Phase-level dependencies**:
   - Phase 2 (Foundational) blocks all User Story phases
   - Each phase implicitly depends on the previous phase completing
   ```bash
   # Foundational blocks all user story phases
   bd dep add [US1_PHASE_ID] [FOUNDATIONAL_PHASE_ID]
   bd dep add [US2_PHASE_ID] [FOUNDATIONAL_PHASE_ID]
   # ... etc

   # Sequential phase ordering (optional, for strict ordering)
   bd dep add [PHASE_2_ID] [PHASE_1_ID]
   ```

   **Step 7b: Task-level dependencies within phases**:
   - For tasks WITHOUT `[P]` marker: Create `blocks` dependency on previous task
   - For tasks WITH `[P]` marker: No dependency (parallel by default in beads)
   - Test tasks block their corresponding implementation tasks (if TDD requested)

   ```bash
   # Sequential task: T003 depends on T002
   bd dep add [T003_BEADS_ID] [T002_BEADS_ID]

   # Parallel tasks T004, T005 have no deps on each other
   # (beads parallel by default - no action needed)
   ```

   **Step 7c: Cross-phase dependencies** (from Dependencies section):
   - Parse explicit dependencies from tasks.md Dependencies section
   - Create corresponding beads dependencies

8. **Apply labels**:

   **User story labels**:
   ```bash
   # For each task with [USn] marker
   bd label add [BEADS_ID] US1 --json
   bd label add [BEADS_ID] US2 --json
   ```

   **Parallel marker labels** (optional, for filtering):
   ```bash
   # For each task with [P] marker
   bd label add [BEADS_ID] parallel --json
   ```

   **Test labels**:
   ```bash
   # For tasks in "Tests for" subsections
   bd label add [BEADS_ID] test --json
   ```

   **Phase labels** (for cross-cutting queries):
   ```bash
   bd label add [BEADS_ID] setup --json       # Phase 1 tasks
   bd label add [BEADS_ID] foundational --json # Phase 2 tasks
   bd label add [BEADS_ID] polish --json      # Final phase tasks
   ```

9. **Handle pre-completed tasks**:
   - For any task already marked `[X]` in tasks.md:
   ```bash
   bd close [BEADS_ID] --reason "Pre-completed in tasks.md" --json
   ```

10. **Generate mapping file**:
    - Create `FEATURE_DIR/beads-mapping.json`:
    ```json
    {
      "version": "1.0",
      "created_at": "2025-12-27T10:00:00Z",
      "feature_name": "Feature Name",
      "source_file": "FEATURE_DIR/tasks.md",
      "root_epic": "proj-a1b2",
      "phases": {
        "1": {
          "name": "Setup",
          "beads_id": "proj-a1b2.1",
          "task_count": 3
        },
        "2": {
          "name": "Foundational",
          "beads_id": "proj-a1b2.2",
          "task_count": 6
        },
        "3": {
          "name": "User Story 1 - Login",
          "beads_id": "proj-a1b2.3",
          "user_story": "US1",
          "task_count": 8
        }
      },
      "tasks": {
        "T001": {
          "beads_id": "proj-a1b2.1.1",
          "phase": 1,
          "description": "Create project structure",
          "file_path": null,
          "is_parallel": false,
          "user_story": null,
          "line_number": 42
        },
        "T002": {
          "beads_id": "proj-a1b2.1.2",
          "phase": 1,
          "description": "Initialize Python project with FastAPI",
          "file_path": "pyproject.toml",
          "is_parallel": true,
          "user_story": null,
          "line_number": 43
        }
      },
      "stats": {
        "total_phases": 6,
        "total_tasks": 45,
        "parallel_tasks": 12,
        "user_story_tasks": 32,
        "dependencies_created": 28
      }
    }
    ```

11. **Embed beads IDs in tasks.md** (optional, based on user preference):
    - If user requested inline tracking, update tasks.md:
    ```markdown
    - [ ] T001 Create project structure <!-- beads:proj-a1b2.1.1 -->
    - [ ] T002 [P] Initialize Python project <!-- beads:proj-a1b2.1.2 -->
    ```
    - This enables direct sync without the mapping file

12. **Verify import integrity**:
    - Run `bd dep tree [ROOT_EPIC_ID]` to visualize hierarchy
    - Run `bd stats --json` to confirm issue counts
    - Validate all tasks are accounted for
    - Check for any orphaned issues or broken dependencies

13. **Report summary**:
    Display comprehensive import report:
    ```
    ═══════════════════════════════════════════════════════════
    TRELLIS IMPORT COMPLETE: [FEATURE_NAME]
    ═══════════════════════════════════════════════════════════

    Root Epic: [ROOT_EPIC_ID] - [FEATURE_NAME] Implementation

    PHASES CREATED:
    ┌─────────┬────────────────────────────┬─────────────┬───────┐
    │ Phase   │ Name                       │ Beads ID    │ Tasks │
    ├─────────┼────────────────────────────┼─────────────┼───────┤
    │ 1       │ Setup                      │ proj-a1b2.1 │ 3     │
    │ 2       │ Foundational               │ proj-a1b2.2 │ 6     │
    │ 3       │ User Story 1 - Login       │ proj-a1b2.3 │ 8     │
    │ 4       │ User Story 2 - Dashboard   │ proj-a1b2.4 │ 10    │
    │ 5       │ Polish                     │ proj-a1b2.5 │ 5     │
    └─────────┴────────────────────────────┴─────────────┴───────┘

    STATISTICS:
    • Total tasks imported: 32
    • Parallel tasks ([P]): 12
    • Sequential tasks: 20
    • Dependencies created: 28
    • Pre-completed tasks: 0

    READY WORK (no blockers):
    • [P1] proj-a1b2.1.1: T001 Create project structure
    • [P1] proj-a1b2.1.2: T002 [P] Initialize Python project
    • [P1] proj-a1b2.1.3: T003 [P] Configure linting tools

    FILES CREATED:
    • FEATURE_DIR/beads-mapping.json

    NEXT STEPS:
    1. Run `bd ready --json` to see available work
    2. Use `/trellis.implement` to execute with beads tracking
    3. Run `bd dep tree [ROOT_EPIC_ID]` to visualize full hierarchy
    4. Run `/trellis.sync` to sync status back to tasks.md
    ═══════════════════════════════════════════════════════════
    ```

## Error Handling

- **beads not installed**: Provide installation instructions from beads repo
- **beads not initialized**: Offer to run `bd init` or provide manual steps
- **tasks.md parsing failures**: Report specific line numbers and parsing issues
- **bd create failures**: Log failed issue, continue with others, report at end
- **dependency cycle detected**: Report cycle, skip problematic dependency, warn user
- **existing issues conflict**: Offer merge strategies or clean re-import

## User Arguments

The following arguments can be passed to customize behavior:

- `--dry-run`: Parse and validate without creating beads issues
- `--no-inline`: Skip embedding beads IDs in tasks.md
- `--inline`: Force embedding beads IDs in tasks.md
- `--force`: Overwrite existing beads-mapping.json without prompting
- `--sync-only`: Only sync status, don't create new issues
- `--verbose`: Show each bd command as it executes
- `--priority-offset N`: Shift all priorities by N (e.g., --priority-offset -1 makes P1→P0)

## Notes

- Beads uses hash-based IDs to prevent collisions across branches/agents
- The mapping file is the source of truth for tasks.md ↔ beads synchronization
- Hierarchical IDs (epic.1.1) provide natural grouping but are auto-assigned by beads
- The `external_ref` field is NOT used in favor of the mapping file for flexibility
- Run `bd sync` after import to ensure changes are committed to git
