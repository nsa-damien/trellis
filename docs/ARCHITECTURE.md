# Architecture

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

## Component Roles

**spec-kit** generates the plan:
- `spec.md` - User stories, acceptance criteria
- `plan.md` - Tech stack, architecture decisions
- `tasks.md` - Implementation breakdown

**beads** tracks execution:
- Dependency graph determines order
- `bd ready` shows unblocked work
- Status persists across sessions
- `bd sync` commits state to git

**Trellis** bridges them:
- Imports task structure into beads hierarchy
- Uses `bd ready` for intelligent ordering
- Syncs completions back to checkboxes

## Hierarchy Mapping

| spec-kit | beads | ID Pattern |
|----------|-------|------------|
| Feature | Root Epic | `proj-a1b2` |
| Phase | Child Epic | `proj-a1b2.1` |
| Task | Issue | `proj-a1b2.1.1` |

## Dependency Rules

| tasks.md Pattern | beads Behavior |
|------------------|----------------|
| Sequential (no `[P]`) | `blocks` previous task |
| `[P]` parallel marker | No dependency |
| Phase N+1 | Blocked until Phase N complete |

## Conflict Resolution

When beads and tasks.md disagree:

| beads | tasks.md | Resolution |
|-------|----------|------------|
| closed | `[ ]` | Auto-update to `[X]` |
| open | `[X]` | Prompt user |
| in_progress | `[X]` | Prompt user |

Use `--force-beads` or `--force-tasks` to override.
