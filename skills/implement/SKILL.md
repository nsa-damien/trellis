---
name: implement
description: Autonomous plan-build-verify engine — decomposes work, dispatches parallel agents, tests, and commits incrementally
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Instructions

### 1. Accept Intent

Determine what to build from one of three sources (checked in order):

1. **User arguments**: If `$ARGUMENTS` has content, that is the work description.
2. **Branch context**: If arguments are empty but you are on a feature branch with recent commits or uncommitted changes, infer intent from the branch name, recent commit messages (`git log --oneline -10`), and any uncommitted diffs (`git diff --stat`).
3. **Scope handoff**: If invoked by `/trellis:scope`, the work description is passed through as arguments.

If none of these yield a clear intent, ask the user: "What would you like to build?" and **STOP** until they respond.

### 2. Analyze Codebase

Before proposing an approach, gather project context:

1. **Codemap**: Check for `CODEMAP.yaml` at the project root. If it exists, read it first — it provides a semantic map of modules, entry points, key types, and dependencies that accelerates navigation. Use it to identify which modules are relevant to the work description before scanning files.
2. **Project type**: Detect language and framework from `package.json`, `tsconfig.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, `Makefile`, or similar.
3. **Existing patterns**: Scan directory structure, identify naming conventions, module organization, import patterns.
4. **Test framework**: Look for test configuration (`jest.config.*`, `vitest.config.*`, `pytest.ini`, `*_test.go`, `Makefile` test targets). Record the test command.
5. **Linting/type checking**: Look for `eslint`, `biome`, `ruff`, `golangci-lint`, `tsc --noEmit`, or similar. Record the lint command.
6. **Dev server**: Check for running dev server or start commands (`npm run dev`, `yarn dev`, `cargo watch`, etc.) for potential visual verification.
7. **Beads availability**: Check if `bd` command is available and `.beads/` directory exists. Record availability for optional progress tracking.

### 3. Propose Approach (ONLY human interaction)

Present a structured proposal:

```
IMPLEMENTATION PLAN
---

Intent: [1-2 sentence summary of what will be built]

Work Units:
1. [unit name] — [brief description] → [agent]
2. [unit name] — [brief description] → [agent]
3. [unit name] — [brief description] → [agent]

Execution:
- Parallel groups: [which units can run simultaneously]
- Serial dependencies: [which units must wait for others]

Verification:
- Tests: [detected test command or "none detected — will skip"]
- Lint: [detected lint command or "none detected — will skip"]
- Visual: [dev server available + browser tools or "not available — will skip"]

Estimated commits: [N]
```

Wait for user confirmation. Accept "yes", "go", "ok", "approved", or similar affirmative.

If the user requests changes to the plan, revise and re-present. This is the ONLY point where human interaction occurs.

**Exception**: If invoked by `/trellis:scope` (i.e., the arguments include `--approved`), skip the proposal and begin execution immediately — scope already obtained user approval.

After approval: **NO MORE human interaction. Run to completion autonomously.**

### 4. Execute Work Units (plan-build-verify loop)

For each work unit, execute the full build-verify-commit cycle:

#### a. Build — Dispatch to Specialized Agent

Route each work unit to the appropriate agent using the Task tool:

**Routing Algorithm** (first match wins):

1. **File Extension Matching**:
   - `.tsx`, `.jsx`, `.vue`, `.svelte` files → `trellis:frontend-developer`
   - `.py` files → `trellis:python-pro`
   - `.go` files → `trellis:golang-pro`
   - `.ts` files (non-frontend context) → `trellis:typescript-pro`

2. **Keyword Matching** (in work unit description):
   - `api`, `endpoint`, `service`, `controller`, `route`, `handler` → `trellis:backend-architect`
   - `migration`, `schema`, `model`, `database`, `table`, `query` → `trellis:database-architect`
   - `component`, `ui`, `page`, `view`, `layout`, `style` → `trellis:frontend-developer`

3. **Multi-Domain Tasks**:
   - If a work unit spans multiple domains, identify the PRIMARY focus (most files or most critical path) and route to that specialist. The specialist handles secondary concerns.

4. **Fallback**:
   - Tasks with unclear scope → `trellis:general-purpose`

**All agents MUST use `model: "opus"`.**

Provide each agent with:
- Work unit description and acceptance criteria
- Relevant file paths and existing code context
- Project conventions detected in step 2
- Any constraints from the overall plan

#### b. Verify — Layered Verification (each layer optional)

After each work unit completes, run verification layers in order. Each layer degrades gracefully when tools are unavailable.

**Layer 1 — Tests** (when test runner detected):
- Run the detected test command (e.g., `npm test`, `pytest`, `go test ./...`)
- If tests pass: proceed
- If tests fail: enter self-correction (see step 4c)
- If no test runner detected: skip, note "Tests: skipped (no test runner detected)" in report

**Layer 2 — Lint and Type Check** (when linter/type checker detected):
- Run the detected lint command (e.g., `eslint .`, `ruff check .`, `tsc --noEmit`)
- If lint passes: proceed
- If lint fails: enter self-correction (see step 4c)
- If no linter detected: skip, note "Lint: skipped (no linter detected)" in report

**Layer 3 — Visual Verification** (UI changes only, when dev server AND browser tools available):
- Check if a dev server is running or can be started
- Check if browser automation is available (Playwright MCP or Chrome DevTools MCP)
- If both available: take screenshot of the affected page/component and compare against the stated intent
- If either unavailable: skip, note "Visual: skipped (no dev server or browser tools)" in report

#### c. Self-Correct (on verification failure)

When any verification layer fails:

```
WHILE attempt < 3:
  1. Analyze the failure output (test errors, lint messages, type errors)
  2. Dispatch the SAME specialist agent with:
     - Original work unit description
     - The failure output
     - Instructions to diagnose and fix
  3. Re-run the failed verification layer
  4. IF passes: break, continue to next layer
  5. IF fails: increment attempt

IF attempts exhausted (3 failures):
  - Commit whatever currently works (if anything)
  - Document the failure: what was tried, what failed, error output
  - Continue to next work unit — NEVER block or prompt the user
```

#### d. Commit — Incremental Git Commits

After a work unit passes verification (or after exhausting retries):

1. `git add` the specific files changed by this work unit (NOT `git add -A`)
2. Commit with a descriptive message: `feat: [brief description of what was built]`
3. Do NOT push after each commit (push happens at the end or on user request)

If `--no-commit` flag is set: skip commits, batch all changes for a single commit at the end.

### 5. Parallel Execution

When multiple work units have no file conflicts, dispatch them simultaneously:

**File Conflict Detection**:
- For each work unit, predict which files it will modify based on the description and project structure
- If two work units mention or are likely to modify the same file: serialize them (different batches)
- If work units target different files: parallelize them

**Batch Partitioning**:
```
FUNCTION partitionIntoBatches(work_units, parallel_limit):
  batches = []
  assigned = set()

  WHILE unassigned units remain:
    batch = []
    batch_files = set()

    FOR each unit in work_units:
      IF unit already assigned: CONTINUE
      IF batch.size >= parallel_limit: BREAK

      unit_files = predictModifiedFiles(unit)
      IF unit_files intersects batch_files: CONTINUE  # Conflict

      batch.add(unit)
      batch_files.addAll(unit_files)
      assigned.add(unit)

    batches.add(batch)

  RETURN batches
```

**Default parallel limit**: 3 (override with `--parallel-limit N`).

Launch all agents in a batch using multiple Task tool calls in a SINGLE response:
```
Task(subagent_type="trellis:[agent1]", model="opus", prompt="[context + task]", description="Build [unit name]")
Task(subagent_type="trellis:[agent2]", model="opus", prompt="[context + task]", description="Build [unit name]")
Task(subagent_type="trellis:[agent3]", model="opus", prompt="[context + task]", description="Build [unit name]")
```

Wait for all agents in the batch to complete before starting the next batch.

If `--no-parallel` flag is set: execute all work units sequentially (parallel_limit=1).

### 6. Beads Integration (optional)

If `bd` command is available and `.beads/` directory exists:

- **Before execution**: Run `bd ready` and `bd stats` to show current state
- **During execution**: For each work unit, if a matching beads issue exists:
  - `bd update <id> --status in_progress` when starting
  - `bd close <id>` when verified and committed
- **After execution**: Run `bd sync` to commit beads state

If `bd` is not available: proceed without beads, rely solely on git commits for tracking. This is not an error.

### 7. Update Codemap

After all work units are processed and committed, update the project's code navigation map:

1. **Check for CODEMAP.yaml** at the project root
2. **If it exists**: Run a non-interactive update:
   - Scan for new modules, removed modules, new/removed entry points, and changed dependencies
   - Auto-apply obvious changes (new files in existing modules, removed files, renamed symbols)
   - Skip interactive enrichment questions — use auto-generated descriptions for new modules
   - Preserve all manually-edited descriptions and custom fields
   - If changes were detected, commit: `docs: update CODEMAP.yaml`
3. **If it does not exist**: Skip silently. Do not create one automatically — the user should run `/trellis:codemap` to generate the initial map interactively.

### 8. Completion Report

After all work units are processed, display:

```
IMPLEMENTATION COMPLETE
---

Built:
  [work unit 1]: [description]
  [work unit 2]: [description]
  [work unit 3]: [description]

Verified:
  Tests: [passed / failed (N issues) / skipped (no test runner)]
  Lint: [passed / failed (N issues) / skipped (no linter)]
  Visual: [verified / skipped (no dev server)]

Commits: [N] commits on branch [branch-name]

Unresolved (if any):
  [issue description + what was tried + error output summary]
```

If all work units succeeded with no unresolved issues, end with:
```
All work units completed and verified. Ready for review.
```

If there are unresolved issues, end with:
```
[N] work units completed. [M] issues remain — see Unresolved above.
```

## User Arguments

- `--dry-run`: Show decomposition plan and agent routing without executing anything
- `--no-parallel`: Force sequential execution of all work units
- `--parallel-limit N`: Maximum concurrent agents per batch (default: 3)
- `--no-commit`: Do not commit after each work unit; batch all changes for a single commit at the end
- `--skip-tests`: Skip test verification layer
- `--skip-lint`: Skip lint and type check verification layer
- `--verbose`: Show detailed agent routing decisions, verification output, and self-correction attempts

## Notes

- After user approval, execution is fully autonomous with ZERO further human input
- Beads integration is optional: works without it, benefits from it when available
- Browser automation (Playwright MCP or Chrome DevTools MCP) is best-effort for visual verification
- Self-correction is bounded: maximum 3 retries per work unit prevents infinite loops
- When retries are exhausted, the engine commits what works, documents the failure, and moves on
- The completion report is the primary output users see
- When invoked by `/trellis:scope`, the approach proposal may be skipped if scope already obtained user approval
- Each agent gets fresh context via a new Task invocation — no state is carried between agents
- Commits are incremental per work unit by default; use `--no-commit` to batch them
