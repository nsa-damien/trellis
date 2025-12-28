# Architecture: spec-kit + beads Integration

## Overview

This document explains how the speckit-beads integration bridges spec-kit's planning
capabilities with beads' LLM-aware execution tracking.

## Component Responsibilities

### spec-kit (Planning Phase)

```
Feature Request
      ↓
  /speckit.spec     → spec.md (user stories, acceptance criteria)
      ↓
  /speckit.plan     → plan.md (tech stack, architecture)
      ↓
  /speckit.tasks    → tasks.md (implementation task breakdown)
```

**Output**: A complete feature specification with actionable tasks organized by
user story and phase.

### beads (Execution Phase)

```
tasks.md
    ↓
bd create (epics, issues)
    ↓
bd dep add (dependencies)
    ↓
bd ready (unblocked work)
    ↓
bd update/close (track progress)
    ↓
bd sync (persist to git)
```

**Capabilities**:
- Hash-based IDs prevent collision across branches/agents
- Dependency graph determines execution order
- `in_progress` status enables work claiming
- Hierarchical epics (feature.phase.task) mirror spec-kit structure
- Code memory provides context continuity

### speckit-beads (Integration Layer)

```
┌─────────────────────────────────────────────────────────────┐
│                     speckit-beads                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  /speckit.beads                                             │
│  ├── Parse tasks.md structure                               │
│  ├── Create beads hierarchy (feature → phase → task)        │
│  ├── Establish dependencies (sequential vs parallel)        │
│  ├── Apply labels (US1, US2, parallel, test)                │
│  └── Generate beads-mapping.json                            │
│                                                             │
│  /speckit.beads-implement                                   │
│  ├── Load mapping and beads state                           │
│  ├── Execute via bd ready (dependency-aware)                │
│  ├── Track status via bd update/close                       │
│  └── Sync completions to tasks.md                           │
│                                                             │
│  /speckit.beads-sync                                        │
│  ├── Compare beads ↔ tasks.md status                        │
│  ├── Detect discrepancies and conflicts                     │
│  ├── Resolve (auto, force-beads, force-tasks)               │
│  └── Update both sources                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

```
                    ┌─────────────┐
                    │  tasks.md   │
                    │  (spec-kit) │
                    └──────┬──────┘
                           │
              /speckit.beads (import)
                           │
                           ▼
┌───────────────────────────────────────────────────────────┐
│                                                           │
│  beads-mapping.json                                       │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ task_id: T001 ←→ beads_id: proj-a1b2.1.1            │  │
│  │ task_id: T002 ←→ beads_id: proj-a1b2.1.2            │  │
│  │ ...                                                 │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                           │
└───────────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   beads     │
                    │  database   │
                    │ (.beads/    │
                    │  beads.db)  │
                    └──────┬──────┘
                           │
         /speckit.beads-implement (execute)
                           │
                           ▼
            ┌──────────────────────────┐
            │    Implementation        │
            │    (code changes)        │
            └──────────────────────────┘
                           │
              /speckit.beads-sync (reconcile)
                           │
                           ▼
                    ┌─────────────┐
                    │  tasks.md   │
                    │  (updated   │
                    │  checkboxes)│
                    └─────────────┘
```

## Schema Mapping

### Hierarchy

| spec-kit | beads | ID Pattern |
|----------|-------|------------|
| Feature | Root Epic | `proj-a1b2` |
| Phase | Epic (child) | `proj-a1b2.1` |
| Task | Issue (child) | `proj-a1b2.1.1` |

### Task Attributes

| tasks.md | beads field | Notes |
|----------|-------------|-------|
| `- [ ]` / `- [X]` | `status` | open, in_progress, closed |
| `T001` | `title` prefix | Also in mapping for lookup |
| `[P]` marker | No dependency | Beads parallel-by-default |
| `[US1]` label | `label` | Applied via `bd label add` |
| Description | `title` | Full task description |
| File path | `description` | Extracted and stored |
| Line number | mapping file | For precise sync |

### Dependencies

| tasks.md pattern | beads dependency |
|------------------|------------------|
| Sequential (no `[P]`) | `blocks` on previous task |
| `[P]` parallel | No dependency created |
| Phase N+1 | `blocks` on Phase N completion |
| Foundational | Blocks all User Story phases |

## Conflict Resolution

When beads and tasks.md disagree:

| Scenario | Beads | tasks.md | Default Resolution |
|----------|-------|----------|-------------------|
| A | closed | `[ ]` | Update tasks.md → `[X]` |
| B | open | `[X]` | Prompt user |
| C | in_progress | `[ ]` | Expected (no conflict) |
| D | in_progress | `[X]` | Prompt user |

**Resolution modes**:
- `--auto`: Auto-resolve A, skip B/D
- `--force-beads`: Beads always wins
- `--force-tasks`: tasks.md always wins

## Benefits of Integration

1. **Dependency-aware execution**: `bd ready` shows only unblocked work
2. **Progress visibility**: `bd stats`, `bd blocked` for instant status
3. **Session recovery**: Beads state persists across Claude Code sessions
4. **Parallel safety**: Hash IDs prevent collision with multi-agent work
5. **Audit trail**: Beads tracks who did what and when
6. **Git integration**: `bd sync` commits beads state to repository
7. **Compatibility**: tasks.md checkboxes stay in sync for spec-kit validation
