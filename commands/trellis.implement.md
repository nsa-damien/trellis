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
   - If NOT found: Display "No beads integration found. Run `/trellis.import` first to import tasks, or use `/speckit.implement` for standard execution." and **STOP**
   - If found: Load mapping, verify beads accessible (`bd info`), verify root epic exists (`bd show [ROOT_EPIC_ID]`)

3. **Check checklists status**
   - Scan FEATURE_DIR/checklists/, count completed vs incomplete items
   - Display status table
   - If incomplete: Ask user to proceed or stop
   - If complete: Proceed automatically

4. **Load implementation context**
   - **REQUIRED**: tasks.md, plan.md
   - **IF EXISTS**: data-model.md, contracts/, research.md, quickstart.md

5. **Project Setup Verification**
   - Create/verify ignore files based on project setup (.gitignore, .dockerignore, .eslintignore, .prettierignore, etc.)
   - Apply technology-appropriate patterns from plan.md tech stack

6. **Get current beads state**:
   - Run: `bd show [ROOT_EPIC_ID]`, `bd ready`, `bd blocked`, `bd stats` (all with --json)
   - Build task status map: completed, in_progress, ready (unblocked), blocked
   - Display progress table showing phases, completion counts, ready work, and blocked tasks

7. **Agent Specialization**:
   Route tasks to specialized agents based on patterns:
   - **frontend-developer**: UI components (.tsx, .jsx, .vue, .svelte files)
   - **backend-architect**: API endpoints, services, controllers
   - **database-architect**: migrations, schema, models, queries
   - **python-pro**, **typescript-pro**, **golang-pro**: Language-specific tasks
   - Extract relevant context from plan.md for each agent type

8. **Parallel Execution with Conflict Detection**:
   - Predict file conflicts: Build file modification map from task descriptions
   - Serialize conflicting tasks (same file, different tasks)
   - Parallelize non-conflicting tasks up to `--parallel-limit N` (default: 3)
   - Launch specialized agents in parallel (single message, multiple Task tool calls)
   - Use Opus model for all implementation agents

9. **Beads-driven execution loop**:
   ```
   WHILE open tasks exist:
     ready_tasks = bd ready | filter by feature epic

     IF ready_tasks empty AND open tasks exist:
       Display blocked status, ask user for guidance, BREAK

     Detect conflicts, partition into parallelizable vs serialized
     Launch parallel batch (up to --parallel-limit)

     FOR each agent result:
       IF successful:
         Validate: files exist, syntax valid, tests pass
         IF validation passed:
           bd close [BEADS_ID]
           Mark [X] in tasks.md
           Display completion + newly unblocked tasks
         ELSE:
           Update beads with failure notes

     Handle partial failures: ask to continue/retry/stop

     IF phase complete:
       Close phase epic, display phase stats

   END WHILE
   ```

10. **Sync tasks.md**: After each task completion, update `- [ ] TASK_ID` to `- [X] TASK_ID` in tasks.md. Beads is source of truth.

11. **Error handling**:
    - Beads connection issues: retry with `--no-daemon`, fall back to tasks.md-only
    - Sync conflicts: Beads authoritative, update tasks.md to match
    - Partial completion: On restart, offer to resume/complete/reset in_progress tasks
    - Dependency cycles: Detect with `bd dep cycles`, report and suggest resolution

12. **Validation**:
    - Verify all issues closed: `bd list --status open | filter by feature epic`
    - Ensure tasks.md checkboxes match beads status
    - **DO NOT close root epic yet - test plan generation comes first**

13. **Generate manual test plan**:
    When all tasks closed, **BEFORE** closing root epic, generate `FEATURE_DIR/test-plan.md`:

    **Gather context**: spec.md (user stories, acceptance criteria), plan.md (tech stack), contracts/ (API specs), data-model.md (entities), implemented files list

    **Generate test-plan.md** with sections:
    - Test Environment Setup (prerequisites, setup steps, test accounts)
    - Manual Verification Checklist (organized by phase/user story with test cases)
    - Feature Testing Scenarios (happy path, edge cases)
    - Notes (space for tester observations)

    **Customize**: Use actual file paths, component names, API endpoints, commands from implementation. Tailor to tech stack (curl for APIs, DevTools for web, CLI examples, etc.)

    Display: `✓ Manual test plan generated: [FEATURE_DIR]/test-plan.md`

14. **Final sync and epic closure**:
    - Close root epic: `bd close [ROOT_EPIC_ID] --reason "Feature implementation complete"`
    - Run `bd sync` to commit beads changes to git

15. **Completion report**:
    Display final status table (phases, task counts), summary (total tasks, parallel batches, specialized agents used), files modified, beads cleanup status, and verification instructions (follow test-plan.md, run test suite, review against spec.md).

## Execution Modes

- **Default**: Execute all ready tasks until completion or blockage
- **Single-task** (`--task T001`): Execute only specified task
- **Phase** (`--phase N`): Execute only tasks in phase N
- **Dry-run** (`--dry-run`): Show execution plan without making changes
- **Continue** (`--continue`): Resume from last in_progress task

## User Arguments

- `--dry-run`: Show execution plan without changes
- `--task T001`: Execute specific task only
- `--phase N`: Execute phase N only
- `--continue`: Resume from previous session
- `--no-sync`: Don't sync to tasks.md (beads only)
- `--verbose`: Show all bd commands
- `--force`: Continue past failures without prompting
- `--parallel-limit N`: Max concurrent agents per batch (default: 3)
- `--no-parallel`: Force sequential execution (parallel-limit=1)

## Notes

- Requires `/trellis.import` to be run first
- Beads is source of truth; tasks.md kept in sync for compatibility
- Run `bd sync` at end of session to commit beads changes to git
- For standard execution without beads, use `/speckit.implement`
