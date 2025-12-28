# AGENTS.md - Trellis Integration Snippet

> Add this content to your project's AGENTS.md file to enable automatic beads awareness
> when using standard `/speckit.implement` command.

---

## Trellis Integration with spec-kit

This project uses [Trellis](https://github.com/YOUR_USERNAME/trellis) to integrate
[beads](https://github.com/steveyegge/beads) LLM-aware task tracking with
[spec-kit](https://github.com/github/spec-kit) planning workflows.

### Automatic Beads Detection

When executing `/speckit.implement` and a `beads-mapping.json` file exists in the feature directory:

1. **Use beads as the source of truth** for task status and execution ordering
2. **Get next tasks from `bd ready --json`** instead of linear tasks.md scanning
3. **Update task status via beads commands**:
   - `bd update <id> --status in_progress` when starting a task
   - `bd close <id> --reason "..."` when completing a task
4. **Sync completed status back to tasks.md checkboxes** after each task
5. **Report progress using beads queries**:
   - `bd stats --json` for overall progress
   - `bd blocked --json` for dependency analysis

### Trellis Commands Available

If Trellis integration is set up, prefer these commands:

| Command | Purpose |
|---------|---------|
| `/trellis.import` | Import tasks.md into beads |
| `/trellis.implement` | Execute with full beads tracking |
| `/trellis.sync` | Reconcile beads ↔ tasks.md |
| `/trellis.ready` | Show available work (no blockers) |
| `/trellis.status` | Project health and statistics |

### Key Differences from Standard Execution

| Aspect | Without Beads | With Trellis |
|--------|---------------|--------------|
| Task order | Linear from tasks.md | Dependency-driven via `bd ready` |
| Status tracking | Markdown checkboxes | Beads database (synced to tasks.md) |
| Blocked detection | Manual `[P]` markers | Automatic via dependencies |
| Session recovery | Re-read tasks.md | Beads state persists |
| Progress query | Parse markdown | `bd stats --json` |

### Session Workflow

```bash
# Start of session - check beads state
bd ready --json

# During implementation - beads tracks progress
bd update <id> --status in_progress
# ... do work ...
bd close <id> --reason "Implementation complete"

# End of session - sync to git
bd sync
```

### Mapping File Location

The Trellis integration stores mapping data in:
```
specs/[feature-name]/beads-mapping.json
```

This file maps spec-kit task IDs (T001, T002, etc.) to beads issue IDs.
