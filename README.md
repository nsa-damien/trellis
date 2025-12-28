# Trellis

> Integrate [spec-kit](https://github.com/github/spec-kit) planning with [beads](https://github.com/steveyegge/beads) LLM-aware issue tracking for Claude Code workflows.

## Overview

Trellis bridges two powerful tools:

- **spec-kit**: Structured feature specification and task decomposition
- **beads**: LLM-optimized issue tracking with dependency management and code memory

**The problem**: spec-kit generates excellent task breakdowns in `tasks.md`, but checkbox-based tracking lacks dependency awareness, progress queries, and session recovery.

**The solution**: Import spec-kit tasks into beads for intelligent execution ordering, then keep both in sync.

## Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PLANNING PHASE                               │
│                        (spec-kit)                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   /speckit.spec  →  /speckit.plan  →  /speckit.tasks                │
│        ↓                  ↓                  ↓                      │
│    spec.md            plan.md            tasks.md                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       INTEGRATION PHASE                             │
│                       (Trellis)                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   /trellis.import                                                   │
│        ↓                                                            │
│   • Creates beads epic hierarchy                                    │
│   • Imports tasks with dependencies                                 │
│   • Generates beads-mapping.json                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       EXECUTION PHASE                               │
│                       (Trellis)                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   /trellis.implement                                                │
│        ↓                                                            │
│   • Uses `bd ready` for task ordering                               │
│   • Tracks status via beads                                         │
│   • Syncs completions to tasks.md                                   │
│                                                                     │
│   /trellis.sync  (as needed)                                        │
│        ↓                                                            │
│   • Reconciles beads ↔ tasks.md                                     │
│   • Resolves conflicts                                              │
│                                                                     │
│   /trellis.ready  (quick check)                                     │
│        ↓                                                            │
│   • Shows unblocked tasks                                           │
│                                                                     │
│   /trellis.status  (overview)                                       │
│        ↓                                                            │
│   • Project health and statistics                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- [beads](https://github.com/steveyegge/beads) installed (`go build -o bd ./cmd/bd`)
- [spec-kit](https://github.com/github/spec-kit) initialized in your project

### Install Commands

**Option A: User-level (all projects)**

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/trellis.git

# Copy commands to Claude Code user commands directory
mkdir -p ~/.claude/commands
cp trellis/commands/*.md ~/.claude/commands/
```

**Option B: Project-level (single project)**

```bash
# From your project root
mkdir -p .claude/commands
cp /path/to/trellis/commands/*.md .claude/commands/
```

### Verify Installation

```bash
# In Claude Code, these commands should now be available:
claude
> /trellis.import --help
> /trellis.implement --help
> /trellis.sync --help
> /trellis.ready --help
> /trellis.status --help
```

## Commands

### `/trellis.import`

Import `tasks.md` into beads issue tracker.

**What it does:**
1. Parses tasks.md structure (phases, tasks, dependencies)
2. Creates beads epic hierarchy (feature → phases → tasks)
3. Establishes dependencies (sequential tasks, phase ordering)
4. Applies labels (US1, US2, parallel, test, etc.)
5. Generates `beads-mapping.json` for sync

**Usage:**
```
/trellis.import                    # Standard import
/trellis.import --dry-run          # Preview without creating issues
/trellis.import --force            # Overwrite existing mapping
```

**Output:**
- Beads issues with hierarchical IDs (e.g., `proj-a1b2.1.1`)
- `FEATURE_DIR/beads-mapping.json` mapping file

---

### `/trellis.implement`

Execute implementation using beads for task tracking.

**What it does:**
1. Uses `bd ready` to determine executable tasks (respects dependencies)
2. Claims tasks with `in_progress` status
3. Executes implementation following spec-kit context
4. Closes tasks and syncs to tasks.md checkboxes
5. Automatically detects newly unblocked tasks

**Usage:**
```
/trellis.implement                  # Execute all ready tasks
/trellis.implement --task T005      # Execute specific task
/trellis.implement --phase 3        # Execute phase 3 only
/trellis.implement --continue       # Resume from last session
/trellis.implement --dry-run        # Show execution plan
```

**Key differences from `/speckit.implement`:**

| Aspect | speckit.implement | trellis.implement |
|--------|-------------------|-------------------|
| Task order | Linear scan | Dependency-driven (`bd ready`) |
| Status tracking | Markdown checkboxes | Beads database |
| Progress query | Parse markdown | `bd stats --json` |
| Blocked detection | Manual `[P]` markers | Automatic via dependencies |
| Session recovery | Re-read tasks.md | Beads state persists |

---

### `/trellis.sync`

Bidirectional sync between beads and tasks.md.

**What it does:**
1. Compares status in both sources
2. Detects discrepancies and conflicts
3. Resolves or prompts for resolution
4. Updates both sources to match

**Usage:**
```
/trellis.sync                       # Interactive sync
/trellis.sync --auto                # Auto-resolve non-conflicts
/trellis.sync --force-beads         # Beads is authoritative
/trellis.sync --force-tasks         # tasks.md is authoritative
/trellis.sync --dry-run             # Preview changes
/trellis.sync --validate            # Check status only
```

**Conflict scenarios:**

| Beads Status | tasks.md | Resolution |
|--------------|----------|------------|
| closed | `[ ]` | Auto-update tasks.md to `[X]` |
| open | `[X]` | Prompt: close beads or reopen tasks.md |
| in_progress | `[X]` | Prompt: complete beads or reopen tasks.md |

---

### `/trellis.ready`

Quick check of available work.

**What it does:**
1. Queries beads for unblocked tasks
2. Displays ready work with priorities
3. Suggests next actions

**Usage:**
```
/trellis.ready                      # Show all ready tasks
/trellis.ready --priority P1        # Filter by priority
/trellis.ready --limit 5            # Show top 5 only
```

---

### `/trellis.status`

Project health and statistics overview.

**What it does:**
1. Shows overall progress (open/in-progress/closed)
2. Displays work by priority
3. Lists ready, in-progress, and blocked work
4. Runs health checks

**Usage:**
```
/trellis.status                     # Full status report
/trellis.status --quiet             # Compact one-line summary
/trellis.status --health            # Health checks only
```

## Mapping File

The integration creates `beads-mapping.json` in your feature directory:

```json
{
  "version": "1.0",
  "created_at": "2025-12-27T10:00:00Z",
  "last_synced_at": "2025-12-27T15:30:00Z",
  "feature_name": "User Authentication",
  "source_file": "/specs/001-auth/tasks.md",
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
      "is_parallel": false,
      "line_number": 42
    }
  }
}
```

## Schema Mapping

| spec-kit Concept | beads Concept | Notes |
|------------------|---------------|-------|
| Feature | Root Epic | Parent of all phases |
| Phase | Epic | Child of feature, parent of tasks |
| Task | Issue | Child of phase |
| `[P]` marker | No dependency | Beads is parallel-by-default |
| Sequential (no `[P]`) | `blocks` dependency | Explicit dep on prior task |
| `[US1]` label | Label | `bd label add <id> US1` |
| Priority P1-P4 | Priority 1-4 | Direct mapping |
| `- [ ]` / `- [X]` | status open/closed | Sync target |

## Example Session

```bash
# 1. Generate spec-kit tasks (standard spec-kit workflow)
claude
> /speckit.tasks

# 2. Import to beads
> /trellis.import

# Output:
# ═══════════════════════════════════════════════════════════
# TRELLIS IMPORT COMPLETE: User Authentication
# ═══════════════════════════════════════════════════════════
# Root Epic: proj-a1b2
# Total tasks imported: 32
# Dependencies created: 28
# Ready work: T001, T002, T003

# 3. Execute with beads tracking
> /trellis.implement

# Output:
# ▶ Starting: T001 - Create project structure
# ✓ Completed: T001
#   Phase 1: 1/3 complete | Overall: 1/32 (3%)
#   Newly unblocked: (none - T002, T003 already ready)
#
# ▶ Starting: T002 - Initialize Python project
# ...

# 4. Check progress anytime
> /trellis.status
> /trellis.ready

# Or via beads CLI:
> exit
$ bd stats
$ bd ready
$ bd blocked

# 5. Resume later
claude
> /trellis.implement --continue

# 6. Manual sync if needed
> /trellis.sync --validate
```

## Beads CLI Quick Reference

```bash
# View ready work (unblocked tasks)
bd ready --json

# View blocked work
bd blocked --json

# View full dependency tree
bd dep tree <epic-id>

# Check overall progress
bd stats --json

# Update task status
bd update <id> --status in_progress
bd close <id> --reason "Implementation complete"

# Sync beads changes to git
bd sync
```

## Configuration

### AGENTS.md Fallback

Add to your project's `AGENTS.md` for automatic beads awareness even with standard `/speckit.implement`:

```markdown
## Trellis Integration

When executing `/speckit.implement` and `beads-mapping.json` exists in the feature directory:

1. Use beads as the source of truth for task status and ordering
2. Get next tasks from `bd ready --json` instead of linear tasks.md scanning
3. Update task status via `bd update/close` commands
4. Sync completed status back to tasks.md checkboxes
5. Report progress using `bd stats --json` and `bd blocked --json`
```

### Environment Variables

```bash
# Optional: Set beads database path (defaults to .beads/beads.db)
export BEADS_DB=/path/to/.beads/beads.db

# Optional: Disable beads daemon (for CI/CD or sandboxed environments)
export BEADS_NO_DAEMON=1
```

## Troubleshooting

### "No beads integration found"

Run `/trellis.import` first to import tasks.md into beads.

### "Beads not initialized"

Run `bd init` in your project root to initialize beads.

### Sync conflicts

Use `/trellis.sync --force-beads` or `--force-tasks` to resolve all conflicts in one direction.

### Stale daemon

```bash
bd daemons health --json
bd daemons restart /path/to/project
```

### Re-import after tasks.md changes

```bash
/trellis.import --force
```

## Contributing

1. Fork this repository
2. Create a feature branch
3. Make changes to commands in `commands/`
4. Test with a sample spec-kit project
5. Submit a pull request

## License

MIT License - See [LICENSE](LICENSE) for details.

## Related Projects

- [spec-kit](https://github.com/github/spec-kit) - Feature specification framework
- [beads](https://github.com/steveyegge/beads) - LLM-aware issue tracking
- [Claude Code](https://claude.ai/code) - Anthropic's agentic coding tool
