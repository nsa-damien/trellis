# Agent Instructions

This project uses **bd** (beads) for issue tracking.

## Commands

```bash
bd ready                              # Find available work
bd show <id>                          # View issue details
bd update <id> --status in_progress   # Claim work
bd close <id>                         # Complete work
bd sync                               # Sync with git
```

## Trellis Commands

```bash
/trellis.import       # Import tasks.md into beads
/trellis.implement    # Execute with beads tracking
/trellis.sync         # Sync beads ↔ tasks.md
/trellis.ready        # Show available work
/trellis.status       # Project health overview
```

## Session End Checklist

Before ending a session, complete ALL steps:

```bash
git status            # Check uncommitted changes
git add <files>       # Stage changes
bd sync               # Sync beads state
git commit -m "..."   # Commit code
git push              # Push to remote
```

Work is not complete until `git push` succeeds.
