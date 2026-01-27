# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Trellis bridges spec-kit planning with beads issue tracking for Claude Code. It imports tasks from `tasks.md` into beads for dependency-aware execution, then keeps both in sync.

**Architecture:**
```
spec-kit (tasks.md) → /trellis.import → beads issues
                      /trellis.implement → dependency-aware execution
                      /trellis.sync → bidirectional sync
```

## Key Commands

### Trellis Commands (this plugin)
| Command | Purpose |
|---------|---------|
| `/trellis.import` | Import tasks.md into beads with dependency graph |
| `/trellis.implement` | Execute tasks using beads ordering |
| `/trellis.sync` | Reconcile beads ↔ tasks.md status |
| `/trellis.ready` | Show unblocked tasks |
| `/trellis.status` | Project health overview |
| `/trellis.push` | Commit and push with changelog updates |
| `/trellis.pr` | Create a pull request for the current branch |
| `/trellis.release` | Create release from PR with version tag |
| `/trellis.codemap` | Generate/update CODEMAP.yaml for LLM navigation |

**Typical Workflow:**
```
/trellis.push → /trellis.pr → /trellis.release
     ↓              ↓              ↓
  commit+push   create PR    merge+tag+release
```

Note: `/trellis.release` will auto-create a PR if one doesn't exist, so `/trellis.pr` is optional.

### Beads Commands
```bash
bd ready                              # Find available work
bd show <id>                          # View issue details
bd update <id> --status in_progress   # Claim work
bd close <id>                         # Complete work
bd sync                               # Sync with git
bd stats                              # Project statistics
```

## Repository Structure

```
skills/              # Trellis skills (*.md files)
agents/              # Trellis subagents
.claude-plugin/     # Plugin manifest for Claude Code
.specify/           # spec-kit templates and scripts
  templates/        # Document templates (spec, plan, tasks)
  scripts/          # Helper scripts (check-prerequisites.sh)
  memory/           # Project constitution
specs/              # Feature specifications
  {feature}/        # Per-feature directory
    spec.md         # Feature specification
    plan.md         # Implementation plan
    tasks.md        # Task breakdown
    beads-mapping.json  # Task ID ↔ beads ID mapping
docs/               # Documentation
  ARCHITECTURE.md   # Data flow and component roles
  release/          # Release notes per version
```

## Hierarchy Mapping

| spec-kit | beads | ID Pattern |
|----------|-------|------------|
| Feature | Root Epic | `proj-a1b2` |
| Phase | Child Epic | `proj-a1b2.1` |
| Task | Issue | `proj-a1b2.1.1` |
| Sequential task | `blocks` dependency | Enforces order |
| `[P]` parallel marker | No dependency | Can run anytime |

## Session End Checklist

Before ending a session, complete ALL steps:

```bash
git status            # Check uncommitted changes
git add <files>       # Stage changes
bd sync               # Sync beads state
git commit -m "..."   # Commit code
bd sync               # Commit any new beads changes
git push              # Push to remote
```

Work is not complete until `git push` succeeds.

## Development

To work on Trellis itself:

```bash
claude --plugin-dir /path/to/trellis
```

Skills are markdown files in `skills/<skill-name>/SKILL.md` and subagents are defined in `agents/`. Changes require restart to take effect.

## Active Technologies
- Markdown (Claude Code command file format) + Claude Code Task tool, beads CLI (`bd`), speckit scripts (002-implement-concurrency)
- N/A (stateless command orchestration; beads handles persistence) (002-implement-concurrency)

## Recent Changes
- 002-implement-concurrency: Added Markdown (Claude Code command file format) + Claude Code Task tool, beads CLI (`bd`), speckit scripts
