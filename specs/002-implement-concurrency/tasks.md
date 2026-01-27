# Tasks: Implement Concurrency Enhancement

**Input**: Design documents from `/specs/002-implement-concurrency/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Tests**: Manual testing only (per quickstart.md); no automated tests required.

**Organization**: Tasks modify a single file (`skills/trellis.implement/SKILL.md`). Organized by user story to enable incremental validation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (not applicable - single file)
- **[Story]**: Which user story this task belongs to (US1-US5)
- File path: All tasks modify `skills/trellis.implement/SKILL.md`

---

## Phase 1: Setup

**Purpose**: Backup and preparation

- [X] T001 Create backup of current `skills/trellis.implement/SKILL.md` as `skills/trellis.implement/SKILL.md.backup`
- [X] T002 Review current command structure and identify sections to modify

**Checkpoint**: Ready to begin modifications

---

## Phase 2: Foundational (Core Loop Restructure)

**Purpose**: Establish the new execution loop structure that all user stories depend on

**⚠️ CRITICAL**: The loop structure must be correct before user story features can be added

- [X] T003 Rewrite step 9 (Beads-driven execution loop) to remove per-task user prompts in `skills/trellis.implement/SKILL.md`
- [X] T004 Update step 9 to continue automatically after each successful task completion in `skills/trellis.implement/SKILL.md`
- [X] T005 Update step 9 to only break loop on genuine blockers (empty ready queue, batch-wide failure) in `skills/trellis.implement/SKILL.md`
- [X] T006 Remove "Handle partial failures: ask to continue/retry/stop" for single failures in step 9 of `skills/trellis.implement/SKILL.md`
- [X] T007 Update phase transition to happen silently (no prompts) in step 9 of `skills/trellis.implement/SKILL.md`

**Checkpoint**: Core loop runs continuously without interruption

---

## Phase 3: User Story 1 - Continuous Execution (Priority: P1) 🎯 MVP

**Goal**: Process all beads continuously until completion, stopping only for genuine blockers

**Independent Test**: Run `/trellis.implement` on a multi-bead feature and verify no prompts between successful tasks

### Implementation for User Story 1

- [X] T008 [US1] Add explicit WHILE loop continuation condition (open beads exist for feature) to step 9 in `skills/trellis.implement/SKILL.md`
- [X] T009 [US1] Add batch success handling that proceeds to next batch without prompting in step 9 of `skills/trellis.implement/SKILL.md`
- [X] T010 [US1] Add auto-close for phase epics when all phase tasks complete in step 9 of `skills/trellis.implement/SKILL.md`
- [X] T011 [US1] Update completion report (step 15) to show continuous execution stats in `skills/trellis.implement/SKILL.md`

**Checkpoint**: US1 complete - command runs through all tasks without stopping

---

## Phase 4: User Story 2 - Fresh Agent Per Bead (Priority: P1)

**Goal**: Each bead gets a fresh agent via Task tool with no shared state

**Independent Test**: Run with `--verbose` and verify each bead shows a separate Task invocation with no `resume` parameter

### Implementation for User Story 2

- [X] T012 [US2] Document fresh agent requirement in step 8 (Parallel Execution) of `skills/trellis.implement/SKILL.md`
- [X] T013 [US2] Add explicit "NO resume parameter" instruction to Task invocation pattern in step 8 of `skills/trellis.implement/SKILL.md`
- [X] T014 [US2] Add context assembly instructions: include spec summary, plan context, bead requirements for each agent in step 8 of `skills/trellis.implement/SKILL.md`

**Checkpoint**: US2 complete - each bead uses isolated fresh agent

---

## Phase 5: User Story 3 - Intelligent Agent Routing (Priority: P1)

**Goal**: Automatically select specialized agent based on task characteristics

**Independent Test**: Run with mixed task types (frontend, backend, database) and verify correct agent selection

### Implementation for User Story 3

- [X] T015 [US3] Expand step 7 (Agent Specialization) with complete routing algorithm from research.md in `skills/trellis.implement/SKILL.md`
- [X] T016 [US3] Add file extension pattern matching logic (.tsx→frontend, .py→python-pro, etc.) to step 7 of `skills/trellis.implement/SKILL.md`
- [X] T017 [US3] Add keyword-based routing (API→backend-architect, migration→database-architect) to step 7 of `skills/trellis.implement/SKILL.md`
- [X] T018 [US3] Add multi-domain task handling: route to primary focus specialist (AR-009) in step 7 of `skills/trellis.implement/SKILL.md`
- [X] T019 [US3] Add general-purpose fallback for unclear scope tasks in step 7 of `skills/trellis.implement/SKILL.md`
- [X] T020 [US3] Specify Opus model requirement for all implementation agents (AR-008) in step 7 of `skills/trellis.implement/SKILL.md`

**Checkpoint**: US3 complete - tasks route to appropriate specialized agents

---

## Phase 6: User Story 4 - Maximized Parallel Execution (Priority: P2)

**Goal**: Execute non-conflicting beads concurrently using single-message multi-Task pattern

**Independent Test**: Run on feature with 3+ independent tasks and observe parallel agent launches

### Implementation for User Story 4

- [X] T021 [US4] Update step 8 with explicit single-message multi-Task pattern from research.md in `skills/trellis.implement/SKILL.md`
- [X] T022 [US4] Add file conflict detection algorithm from data-model.md to step 8 of `skills/trellis.implement/SKILL.md`
- [X] T023 [US4] Add batch partitioning logic that respects parallel-limit and conflicts to step 8 of `skills/trellis.implement/SKILL.md`
- [X] T024 [US4] Add instruction to launch all batch agents in single response message in step 8 of `skills/trellis.implement/SKILL.md`
- [X] T025 [US4] Update completion report (step 15) to show parallel batches executed in `skills/trellis.implement/SKILL.md`

**Checkpoint**: US4 complete - independent tasks run in parallel

---

## Phase 7: User Story 5 - Graceful Blocker Handling (Priority: P2)

**Goal**: Clear, actionable blocker messages with explicit resolution options

**Independent Test**: Create a blocked scenario and verify message includes what/why/options

### Implementation for User Story 5

- [X] T026 [US5] Add Blocker Categories section (BC-001 through BC-005) to command documentation in `skills/trellis.implement/SKILL.md`
- [X] T027 [US5] Implement blocker detection for BC-004 (all blocked) in step 9 of `skills/trellis.implement/SKILL.md`
- [X] T028 [US5] Add actionable blocker message format from research.md to step 9 of `skills/trellis.implement/SKILL.md`
- [X] T029 [US5] Add resolution options (retry, skip, stop) to blocker handling in step 9 of `skills/trellis.implement/SKILL.md`
- [X] T030 [US5] Update error handling (step 11) with blocker category references in `skills/trellis.implement/SKILL.md`

**Checkpoint**: US5 complete - blockers show clear actionable messages

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and documentation

- [X] T031 Update command description (YAML frontmatter) to reflect enhanced capabilities in `skills/trellis.implement/SKILL.md`
- [X] T032 Update Notes section with new behavior summary in `skills/trellis.implement/SKILL.md`
- [X] T033 Verify all existing flags still work as documented in `skills/trellis.implement/SKILL.md`
- [X] T034 Run quickstart.md validation tests manually
- [X] T035 Remove backup file `skills/trellis.implement/SKILL.md.backup` after successful validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational (Phase 2)
  - US1, US2, US3 are P1 priority - implement in order
  - US4, US5 are P2 priority - implement after P1 stories
- **Polish (Phase 8)**: Depends on all user stories

### User Story Dependencies

- **US1 (Continuous Execution)**: Core requirement - enables other stories
- **US2 (Fresh Agents)**: Independent of US1; can be parallel
- **US3 (Agent Routing)**: Independent of US1, US2; can be parallel
- **US4 (Parallel Execution)**: Benefits from US1-US3 being complete
- **US5 (Blocker Handling)**: Benefits from US1 loop structure

### Within Each User Story

Since all tasks modify the same file, they MUST be sequential (no [P] markers).

### Parallel Opportunities

**Limited due to single-file constraint.** However:
- Different team members could work on different user stories in separate branches
- Each story branch would modify trellis.implement.md independently
- Stories would merge back with conflict resolution

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (core loop)
3. Complete Phase 3: User Story 1 (continuous execution)
4. **STOP and VALIDATE**: Test continuous execution works
5. This alone provides value - no manual prompts between tasks

### Incremental Delivery

1. Setup + Foundational → Loop structure ready
2. Add US1 → Continuous execution (MVP!)
3. Add US2 → Fresh agents per task
4. Add US3 → Intelligent routing
5. Add US4 → Parallel execution
6. Add US5 → Better blocker messages
7. Polish → Documentation and cleanup

Each increment is independently valuable and testable.

---

## Notes

- All tasks modify single file: `skills/trellis.implement/SKILL.md`
- No [P] markers - single-file changes must be sequential
- [Story] labels enable tracking which user story each task serves
- Backup created in T001 enables rollback if needed
- Manual testing via quickstart.md after each user story
- Commit after each user story phase for safe increments
