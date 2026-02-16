---
name: architecture
description: Trellis invariants, data flow, and integration rules (spec-kit ↔ beads)
user-invocable: false
---

# Trellis Architecture

Trellis bridges spec-kit planning with beads issue tracking for Claude Code, enabling dependency-aware task execution with persistent state across sessions.

## Data Flow

```
┌─────────────┐     /trellis:import      ┌─────────────┐
│  tasks.md   │ ──────────────────────→  │   beads     │
│  (spec-kit) │                          │  database   │
└──────┬──────┘                          └──────┬──────┘
       │                                        │
       │         beads-mapping.json             │
       │    (task_id ←→ beads_id mapping)       │
       │                                        │
       ↓           /trellis:sync                ↓
┌─────────────┐  ←────────────────────→  ┌─────────────┐
│  checkboxes │                          │   status    │
│  [ ] / [X]  │                          │   updates   │
└─────────────┘                          └─────────────┘
```

## Core Invariants

These rules MUST be preserved:

1. **Beads is source of truth** — Once tasks are imported, beads owns task state. Never update tasks.md status without checking beads first.

2. **Mapping file is authoritative** — `FEATURE_DIR/beads-mapping.json` is the single source for task_id ↔ beads_id relationships.

3. **Checkboxes reflect beads** — tasks.md checkboxes should only be updated to reflect beads status, not the other way around (unless using `--force-tasks`).

4. **Epic closure gates** — A feature root epic should not be closed until test plan generation is complete.

5. **Session persistence** — Work state persists in beads across sessions; always check `bd ready` to resume work.

## Component Roles

### spec-kit (Planning)

Generates the implementation plan:
- `spec.md` — User stories, acceptance criteria, requirements
- `plan.md` — Tech stack, architecture decisions, approach
- `tasks.md` — Implementation breakdown with phases and tasks

spec-kit output is **input-only** for Trellis. Once imported, edits flow through beads.

### beads (Execution Tracking)

Tracks work execution with:
- **Dependency graph** — Determines task execution order
- **Status persistence** — State survives session boundaries
- **Git integration** — `bd sync` commits state changes
- **Ready queue** — `bd ready` shows unblocked work

Key commands:
```bash
bd ready                    # What can I work on now?
bd show <id>               # Issue details + dependencies
bd update <id> --status=X  # Change status
bd close <id>              # Mark complete
bd sync                    # Commit to git
```

### Trellis (Bridge)

Connects spec-kit planning to beads execution:

| Skill | Purpose |
|-------|---------|
| `/trellis:import` | Parse tasks.md → create beads hierarchy |
| `/trellis:implement` | Execute tasks using `bd ready` ordering |
| `/trellis:sync` | Reconcile beads ↔ tasks.md status |
| `/trellis:ready` | Quick view of available work |
| `/trellis:status` | Project health overview |

## Hierarchy Mapping

spec-kit structure maps to beads hierarchy:

| spec-kit | beads | ID Pattern | Example |
|----------|-------|------------|---------|
| Feature | Root Epic | `proj-XXXX` | `proj-a1b2` |
| Phase | Child Epic | `proj-XXXX.N` | `proj-a1b2.1` |
| Task | Issue | `proj-XXXX.N.M` | `proj-a1b2.1.3` |

### ID Generation

- Feature epic: Random 4-char hex suffix
- Phase epic: Sequential `.1`, `.2`, etc.
- Task issue: Sequential within phase `.1.1`, `.1.2`, etc.

## Dependency Rules

### From tasks.md Structure

| tasks.md Pattern | beads Behavior |
|------------------|----------------|
| Sequential tasks (no marker) | Each task `blocks` the previous |
| `[P]` parallel marker | No blocking dependency |
| Phase N+1 | Blocked until all Phase N tasks complete |
| Subtask under task | Child blocks parent completion |

### Dependency Commands

```bash
bd dep add <issue> <depends-on>  # issue depends on depends-on
bd dep remove <issue> <dep>      # Remove dependency
bd blocked                       # Show all blocked issues
```

### Ready Calculation

A task is "ready" when:
1. Status is `open` (not `in_progress`, not `closed`)
2. All blocking dependencies are `closed`
3. Parent epic is not `closed`

## Conflict Resolution

When beads and tasks.md status disagree:

| beads | tasks.md | Default Resolution |
|-------|----------|-------------------|
| `closed` | `[ ]` unchecked | Auto-update to `[X]` |
| `open` | `[X]` checked | Prompt user for decision |
| `in_progress` | `[X]` checked | Prompt user for decision |

Override flags:
- `--force-beads` — Beads status wins, update tasks.md
- `--force-tasks` — tasks.md wins, update beads

## Repository Structure

```
project/
├── .beads/                    # Beads database
│   ├── beads.db              # SQLite database
│   └── config.yaml           # Beads configuration
├── specs/                     # Feature specifications
│   └── {feature-name}/       # Per-feature directory
│       ├── spec.md           # Requirements
│       ├── plan.md           # Implementation plan
│       ├── tasks.md          # Task breakdown
│       └── beads-mapping.json # Task ↔ beads ID mapping
├── docs/                      # Documentation
│   ├── ARCHITECTURE.md       # This architecture doc
│   └── release/              # Release notes
└── CHANGELOG.md              # Version history
```

### beads-mapping.json Format

```json
{
  "feature_id": "proj-a1b2",
  "feature_name": "User Authentication",
  "created_at": "2025-01-15T10:30:00Z",
  "mappings": {
    "1": "proj-a1b2.1",
    "1.1": "proj-a1b2.1.1",
    "1.2": "proj-a1b2.1.2",
    "2": "proj-a1b2.2"
  }
}
```

## Skill Interactions

### Typical Workflow

```
/speckit:tasks     →  Generate tasks.md
        ↓
/trellis:import    →  Create beads hierarchy
        ↓
/trellis:implement →  Execute with dependency ordering
        ↓                    ↑
    bd close <id>  ←─────────┘  (per task)
        ↓
/trellis:sync      →  Update tasks.md checkboxes
        ↓
/trellis:push      →  Commit + push
        ↓
/trellis:pr        →  Create pull request
        ↓
/trellis:release   →  Merge + tag + release
```

### Skill Dependencies

| Skill | Requires | Produces |
|-------|----------|----------|
| `import` | tasks.md | beads issues, beads-mapping.json |
| `implement` | beads-mapping.json | Code changes, closed issues |
| `sync` | beads-mapping.json | Updated tasks.md checkboxes |
| `ready` | beads database | Status display |
| `status` | beads database | Health report |
| `push` | Git changes | Commits |
| `pr` | Remote branch | Pull request |
| `release` | Merged PR | Git tag, GitHub release |

## Session Management

### Starting a Session

```bash
bd ready              # Check what's available
bd list --status=in_progress  # Resume any in-progress work
```

### Ending a Session

```bash
bd sync               # Commit beads state
git add <files>       # Stage code changes
git commit -m "..."   # Commit
git push              # Push to remote
```

**Work is not complete until `git push` succeeds.**

### Session Recovery

If Claude context is lost mid-session:
1. `bd list --status=in_progress` — Find active work
2. `bd show <id>` — Review task details
3. Continue implementation

## Error Handling

### Common Issues

| Error | Cause | Resolution |
|-------|-------|------------|
| "No beads integration found" | Missing beads-mapping.json | Run `/trellis:import` |
| "Database locked" | Concurrent beads access | Wait, retry, or restart |
| "Merge conflict in .beads/" | Parallel beads edits | Run `bd sync --resolve` |
| "Task not found in mapping" | tasks.md edited after import | Re-run `/trellis:import --force` |

### Recovery Commands

```bash
bd doctor             # Diagnose issues
bd sync --status      # Check sync state
bd sync --repair      # Attempt auto-repair
```

## Integration Points

### Git Hooks

Beads integrates with git via hooks:
- `post-commit` — Auto-sync after commits
- `post-merge` — Sync after pulls/merges

### beads Daemon

If running, the beads daemon handles:
- Auto-commit of beads changes
- Auto-push to remote
- Auto-pull from remote

Check status: `bd sync --status`

## Best Practices

1. **Always import before implementing** — Don't manually create beads issues for spec-kit tasks.

2. **Use `bd ready` for ordering** — Don't pick random tasks; follow dependency order.

3. **Close via beads, not tasks.md** — Use `bd close <id>`, then `/trellis:sync` to update checkboxes.

4. **Keep mapping file in git** — beads-mapping.json should be committed with the feature.

5. **One feature per mapping** — Each feature directory has its own beads-mapping.json.

6. **Sync before switching features** — Run `/trellis:sync` before working on a different feature.
