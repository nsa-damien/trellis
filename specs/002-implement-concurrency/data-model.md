# Data Model: Implement Concurrency Enhancement

**Feature**: 002-implement-concurrency
**Date**: 2026-01-16

## Overview

This feature modifies a Claude Code command file, not a traditional application with persistent data. The "data model" describes the conceptual entities and their relationships as used by the command's execution logic.

## Entities

### Bead

A unit of work tracked in the beads issue system.

| Attribute | Type | Description |
|-----------|------|-------------|
| id | string | Unique identifier (e.g., `beads-a1b2c3`) |
| title | string | Short description of the task |
| description | string | Full task description with acceptance criteria |
| status | enum | `open`, `in_progress`, `closed` |
| type | enum | `epic`, `task`, `bug`, `feature` |
| parent | string? | Parent epic ID (null for root epic) |
| blocks | string[] | IDs of beads this bead blocks |
| blocked_by | string[] | IDs of beads blocking this bead |

**Source**: `bd show [id] --json`

**State transitions**:
```
open → in_progress → closed
         ↓
       open (on failure/retry)
```

---

### Agent

A specialized subprocess spawned via Task tool to execute a bead.

| Attribute | Type | Description |
|-----------|------|-------------|
| subagent_type | string | Agent type (e.g., `frontend-developer`) |
| model | string | Model to use (always `opus` for implementation) |
| prompt | string | Full task instructions and context |
| description | string | Short summary (3-5 words) |
| result | object | Agent's output and status |

**Lifecycle**:
```
Created → Running → Completed/Failed
```

**Agent types for implementation**:
- `frontend-developer`
- `backend-architect`
- `database-architect`
- `python-pro`
- `typescript-pro`
- `golang-pro`
- `general-purpose`

---

### Batch

A group of beads executed in parallel.

| Attribute | Type | Description |
|-----------|------|-------------|
| beads | Bead[] | Beads in this batch |
| agents | Agent[] | Corresponding agents (1:1 with beads) |
| size | number | Number of beads (≤ parallel-limit) |
| conflicts | string[][] | File conflict groups (serialized within) |

**Constraints**:
- `size <= parallel-limit` (default: 3)
- No two beads in same batch modify same file
- All beads in batch are ready (no blockers)

---

### Blocker

A condition preventing automatic continuation.

| Attribute | Type | Description |
|-----------|------|-------------|
| category | enum | BC-001 through BC-005 |
| bead_id | string? | Affected bead (if applicable) |
| message | string | Human-readable description |
| options | string[] | Available resolution actions |

**Categories**:
- `BC-001`: Missing environment variable
- `BC-002`: External service unavailable
- `BC-003`: Dependency cycle detected
- `BC-004`: All remaining tasks blocked
- `BC-005`: Agent reports inability

---

### ExecutionState

Runtime state of the `/trellis.implement` execution.

| Attribute | Type | Description |
|-----------|------|-------------|
| root_epic_id | string | Feature's root epic in beads |
| feature_dir | string | Path to feature spec directory |
| parallel_limit | number | Max concurrent agents (default: 3) |
| completed_beads | string[] | IDs of closed beads |
| failed_beads | Map<string, string> | Bead ID → failure reason |
| current_batch | Batch? | Currently executing batch |
| blocker | Blocker? | Current blocker (if any) |

**Not persisted**: This state exists only during command execution. Beads system is the source of truth for persistent state.

---

## Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                      ExecutionState                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                     Batch                            │   │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐       │   │
│  │  │   Bead    │  │   Bead    │  │   Bead    │       │   │
│  │  │           │  │           │  │           │       │   │
│  │  │  Agent    │  │  Agent    │  │  Agent    │       │   │
│  │  └───────────┘  └───────────┘  └───────────┘       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Blocker?                          │   │
│  │  (present only when execution cannot continue)       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

Bead Relationships (in beads system):

  Root Epic
      │
      ├── Phase 1 Epic
      │       ├── Task A ──blocks──→ Task B
      │       ├── Task B
      │       └── Task C (independent)
      │
      └── Phase 2 Epic
              ├── Task D ──blocked_by──→ Task A
              └── Task E
```

---

## Agent Routing Logic

```
FUNCTION selectAgent(bead: Bead) → string:
  patterns = extractPatterns(bead.title + bead.description)

  IF patterns.fileExtensions intersects {.tsx, .jsx, .vue, .svelte}:
    RETURN "frontend-developer"

  IF patterns.keywords intersects {api, endpoint, service, controller, route}:
    RETURN "backend-architect"

  IF patterns.keywords intersects {migration, schema, model, database, table}:
    RETURN "database-architect"

  IF patterns.fileExtensions contains .py:
    RETURN "python-pro"

  IF patterns.fileExtensions intersects {.ts, .tsx}:
    RETURN "typescript-pro"

  IF patterns.fileExtensions contains .go:
    RETURN "golang-pro"

  RETURN "general-purpose"
```

---

## File Conflict Detection

```
FUNCTION detectConflicts(beads: Bead[]) → Map<Bead, string[]>:
  fileMap = new Map<string, Bead[]>()

  FOR each bead in beads:
    predictedFiles = predictModifiedFiles(bead)
    FOR each file in predictedFiles:
      fileMap[file].push(bead)

  conflicts = new Map<Bead, string[]>()
  FOR each (file, beads) in fileMap:
    IF beads.length > 1:
      FOR each bead in beads:
        conflicts[bead].push(file)

  RETURN conflicts

FUNCTION partitionBatch(beads: Bead[], parallelLimit: number) → Batch[]:
  conflicts = detectConflicts(beads)
  batches = []
  assigned = new Set()

  WHILE assigned.size < beads.length:
    batch = []
    batchFiles = new Set()

    FOR each bead in beads:
      IF bead in assigned: CONTINUE
      IF batch.length >= parallelLimit: BREAK

      beadFiles = predictModifiedFiles(bead)
      IF beadFiles intersects batchFiles: CONTINUE  # Conflict

      batch.push(bead)
      batchFiles.addAll(beadFiles)
      assigned.add(bead)

    batches.push(batch)

  RETURN batches
```

---

## Notes

- This is a command orchestration layer, not a data persistence layer
- Beads system is the source of truth for task state
- Tasks.md is kept in sync for compatibility but is not authoritative
- Agent routing is heuristic-based; edge cases fall back to general-purpose
