---
name: trellis.implement
description: Execute implementation using beads for task tracking with continuous execution, fresh agents per bead, intelligent routing, and maximized parallelism
disable-model-invocation: true
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

7. **Agent Specialization & Routing**:

   **Routing Algorithm** (execute in order, first match wins):

   1. **File Extension Matching**:
      - `.tsx`, `.jsx`, `.vue`, `.svelte` → `frontend-developer`
      - `.py` → `python-pro`
      - `.go` → `golang-pro`
      - `.ts` (non-frontend) → `typescript-pro`

   2. **Keyword Matching** (in bead title/description):
      - `api`, `endpoint`, `service`, `controller`, `route`, `handler` → `backend-architect`
      - `migration`, `schema`, `model`, `database`, `table`, `query` → `database-architect`
      - `component`, `ui`, `page`, `view`, `layout`, `style` → `frontend-developer`

   3. **Multi-Domain Tasks** (AR-009):
      - If task mentions multiple domains, identify PRIMARY focus (most files or most critical)
      - Route to primary specialist; that agent handles secondary concerns

   4. **Fallback**:
      - Tasks with unclear scope → `general-purpose`

   **Model Requirement** (AR-008): All implementation agents MUST use Opus model via `model: "opus"` parameter.

   **Context for Each Agent**: Include spec summary, relevant plan.md sections, data-model (if applicable), contracts (if applicable), and specific bead requirements.

8. **Parallel Execution with Fresh Agents**:

   **Fresh Agent Requirement**: Each bead MUST get a completely fresh agent instance. NEVER use the `resume` parameter - each Task call starts with clean context.

   **Single-Message Multi-Task Pattern**: To execute beads in parallel, launch multiple agents in a SINGLE assistant response with multiple Task tool calls:

   ```
   FOR batch of ready beads (up to --parallel-limit):
     In ONE response, include multiple Task invocations:
       Task(subagent_type="[agent1]", model="opus", prompt="[full context + task]", description="Implement [bead-id]")
       Task(subagent_type="[agent2]", model="opus", prompt="[full context + task]", description="Implement [bead-id]")
       Task(subagent_type="[agent3]", model="opus", prompt="[full context + task]", description="Implement [bead-id]")
   ```

   **File Conflict Detection**:
   - Parse each bead's title/description for file paths mentioned
   - Build predicted file modification map
   - If two beads mention the same file → serialize them (different batches)
   - If beads mention different files → can parallelize

   **Batch Partitioning**:
   ```
   FUNCTION partitionIntoBatches(ready_beads, parallel_limit):
     batches = []
     assigned = set()

     WHILE unassigned beads remain:
       batch = []
       batch_files = set()

       FOR each bead in ready_beads:
         IF bead already assigned: CONTINUE
         IF batch.size >= parallel_limit: BREAK

         bead_files = predictModifiedFiles(bead)
         IF bead_files intersects batch_files: CONTINUE  # Conflict - skip

         batch.add(bead)
         batch_files.addAll(bead_files)
         assigned.add(bead)

       batches.add(batch)

     RETURN batches
   ```

9. **Continuous Execution Loop**:

   **CRITICAL**: Execute continuously without per-task user prompts. Only stop for genuine blockers.

   ```
   WHILE open beads exist for this feature:
     ready_beads = bd ready --json | filter by feature epic

     # BLOCKER CHECK: All remaining work is blocked
     IF ready_beads is empty AND open beads exist:
       blocked_beads = bd blocked --json | filter by feature epic
       Display blocker summary using ACTIONABLE BLOCKER FORMAT (see below)
       Ask user for guidance
       BREAK

     # Partition into batches respecting parallel-limit and file conflicts
     batches = partitionIntoBatches(ready_beads, parallel_limit)

     FOR each batch:
       # Launch ALL batch agents in SINGLE response (parallel execution)
       Launch Task tools for all beads in batch simultaneously
       Wait for all agents to complete

       successful = []
       failed = []

       FOR each agent result:
         IF successful:
           Validate: files exist, syntax valid
           IF validation passed:
             bd close [BEADS_ID]
             Mark [X] in tasks.md
             successful.add(bead)
             # Commit and push changes (unless --no-commit)
             IF NOT --no-commit:
               git add -A
               git commit -m "feat: complete [BEADS_ID] - [bead title]"
               git push
               Display: "✓ Committed and pushed: [BEADS_ID]"
             # DO NOT prompt user - continue automatically
           ELSE:
             bd update [BEADS_ID] --notes "Validation failed: [reason]"
             failed.add(bead)
         ELSE:
           bd update [BEADS_ID] --notes "Agent failed: [reason]"
           failed.add(bead)

       # Display batch completion summary (no prompt)
       Display: "✓ Batch complete: [successful.count] succeeded, [failed.count] failed"
       Display newly unblocked tasks

       # BLOCKER CHECK: Entire batch failed
       IF successful.count == 0 AND failed.count > 0:
         Display batch failure using ACTIONABLE BLOCKER FORMAT
         Ask user: retry / skip all / stop
         IF stop: BREAK outer loop

     # Phase transition (silent - no prompt)
     IF current phase epic has all tasks closed:
       bd close [PHASE_EPIC_ID] --reason "Phase complete"
       Display: "✓ Phase [N] complete"
       # Continue to next phase automatically

   END WHILE
   ```

10. **Sync tasks.md**: After each task completion, update `- [ ] TASK_ID` to `- [X] TASK_ID` in tasks.md. Beads is source of truth.

11. **Error Handling with Blocker Categories**:

    **Blocker Categories**:
    - **BC-001**: Missing environment variables or configuration
    - **BC-002**: External service unavailable
    - **BC-003**: Dependency cycle detected (`bd dep cycles`)
    - **BC-004**: All remaining tasks blocked by unresolved dependencies
    - **BC-005**: Agent reports inability to complete task

    **Detection**:
    - BC-001/BC-002: Agent reports specific missing resource
    - BC-003: Run `bd dep cycles` - non-empty means cycle exists
    - BC-004: `bd ready` empty but `bd list --status=open` non-empty
    - BC-005: Agent returns failure with explanation

    **ACTIONABLE BLOCKER FORMAT**:
    ```
    ⚠️ BLOCKER: [BC-XXX: Category Name]

    What happened:
      [Specific issue description]

    What was attempted:
      [Agent/operation that failed]

    Resolution options:
      1. [Primary resolution - most likely fix]
      2. [Alternative approach]
      3. Skip this bead and continue with others
      4. Stop execution

    Your choice: [wait for user input]
    ```

    **Fallback Handling**:
    - Beads connection issues: retry with `--no-daemon`, then fall back to tasks.md-only
    - Sync conflicts: Beads authoritative, update tasks.md to match
    - Partial completion: On restart, detect in_progress beads, offer to resume/complete/reset

12. **Validation**:
    - Verify all issues closed: `bd list --status open | filter by feature epic`
    - Ensure tasks.md checkboxes match beads status
    - **DO NOT close root epic yet - test plan generation comes first**

13. **Generate manual test plan**:
    When all tasks closed, **BEFORE** closing root epic, invoke the test plan command:

    ```
    Use the Skill tool to invoke: /trellis.test-plan
    ```

    This generates the complete test infrastructure including:
    - `FEATURE_DIR/test-plan.md` - Manual verification checklist and test scenarios
    - `FEATURE_DIR/tests/manual.{ext}` - Executable test file with logging
    - `FEATURE_DIR/tests/.env.example` - Environment variable template
    - `FEATURE_DIR/tests/USAGE.md` - Instructions for running tests

    Display: `✓ Test plan generated via /trellis.test-plan`

14. **Final sync and epic closure**:
    - Close root epic: `bd close [ROOT_EPIC_ID] --reason "Feature implementation complete"`
    - Run `bd sync` to commit beads changes to git

15. **CODEMAP updates** (if CODEMAP.yaml exists):
    - Scan all files modified during this implementation session (use `git diff --name-only` against the commit before session started, or track files from each bead's agent results)
    - Extract new/changed symbols from modified files
    - Compare against existing `CODEMAP.yaml`
    - If changes detected:
      ```
      "CODEMAP updates detected from implementation:"
      ```
    - For each change, ask sequentially (one at a time):
      ```
      → "New entry point auth/oauth.go:RefreshToken - add to 'authentication'?" [yes/no/different module]
      → "Entry point jobs/legacy.go:OldProcess no longer exists - remove?" [yes/no]
      ```
    - Write updated CODEMAP.yaml if changes accepted
    - If no CODEMAP.yaml exists: Suggest `"Consider running /trellis.codemap to create a code map"`

16. **Completion Report**:

    Display comprehensive summary:

    ```
    ═══════════════════════════════════════════════════════════════
    ✓ IMPLEMENTATION COMPLETE: [Feature Name]
    ═══════════════════════════════════════════════════════════════

    Execution Summary:
    ├── Total beads: [N]
    ├── Successful: [N]
    ├── Failed: [N] (if any)
    ├── Skipped: [N] (if any)
    └── Parallel batches executed: [N]

    Agent Utilization:
    ├── frontend-developer: [N] tasks
    ├── backend-architect: [N] tasks
    ├── database-architect: [N] tasks
    ├── python-pro: [N] tasks
    ├── typescript-pro: [N] tasks
    ├── golang-pro: [N] tasks
    └── general-purpose: [N] tasks

    Continuous Execution Stats:
    ├── User prompts required: [N] (blockers only)
    ├── Automatic transitions: [N]
    └── Execution mode: [continuous/interrupted]

    Files Modified: [list or count]

    Verification:
    ├── Test plan: [FEATURE_DIR]/test-plan.md
    ├── Run test suite: [command]
    └── Review against: spec.md
    ═══════════════════════════════════════════════════════════════
    ```

## Execution Modes

- **Default**: Execute all ready tasks continuously until completion or blocker
- **Single-task** (`--task T001`): Execute only specified task
- **Phase** (`--phase N`): Execute only tasks in phase N
- **Dry-run** (`--dry-run`): Show execution plan without making changes
- **Continue** (`--continue`): Resume from last in_progress task

## User Arguments

- `--dry-run`: Show execution plan without changes
- `--task T001`: Execute specific task only
- `--phase N`: Execute only tasks in phase N only
- `--continue`: Resume from previous session
- `--no-sync`: Don't sync to tasks.md (beads only)
- `--no-commit`: Don't commit and push after each completed bead
- `--verbose`: Show all bd commands and agent routing decisions
- `--force`: Continue past failures without prompting (skip blockers automatically)
- `--parallel-limit N`: Max concurrent agents per batch (default: 3)
- `--no-parallel`: Force sequential execution (parallel-limit=1)

## Notes

- Requires `/trellis.import` to be run first
- Beads is source of truth; tasks.md kept in sync for compatibility
- Run `bd sync` at end of session to commit beads changes to git
- For standard execution without beads, use `/speckit.implement`
- **Continuous execution**: No prompts between successful tasks; only blockers pause execution
- **Fresh agents**: Each bead gets isolated context via new Task invocation (no resume)
- **Parallel execution**: Use single-message multi-Task pattern for concurrent agent launches
- **Auto-commit**: Each completed bead is committed and pushed immediately (disable with `--no-commit`)
