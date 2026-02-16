# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Trellis is an AI-native development workflow plugin for Claude Code. Two-command lifecycle: scope (do the work) and release (ship it).

**Workflow:**
```
/trellis:scope "description"  →  /trellis:release
         ↓                              ↓
  branch+implement+push+PR      merge+tag+publish
```

## Skills

### Primary
| Skill | Purpose |
|-------|---------|
| `/trellis:scope` | **Start new work** — branch + implement + push + PR |
| `/trellis:release` | **Ship it** — merge + tag + GitHub release |

### Supporting
| Skill | Purpose |
|-------|---------|
| `/trellis:implement` | Autonomous build engine (used by scope, or standalone for additional work) |
| `/trellis:status` | Project health, ready work, branch state |
| `/trellis:codemap` | Generate/update CODEMAP.yaml for LLM navigation (recommended starting point) |

### Escape Hatches
| Skill | Purpose |
|-------|---------|
| `/trellis:push` | Manual commit and push |
| `/trellis:pr` | Manual PR creation |

### Beads Commands (optional)
```bash
bd ready                              # Find available work
bd show <id>                          # View issue details
bd update <id> --status in_progress   # Claim work
bd close <id>                         # Complete work
bd sync                               # Sync with git
bd stats                              # Project statistics
```

Beads is optional. Skills check for availability and skip beads-specific steps when not installed.

## Repository Structure

```
skills/              # Trellis skills (*/SKILL.md)
  scope/             # Primary entry point
  implement/         # Autonomous build engine
  status/            # Project health + ready work
  codemap/           # Codebase navigation map (recommended starting point)
  push/              # Manual commit+push
  pr/                # Manual PR creation
  release/           # Merge, tag, publish
  architecture/      # [knowledge] Plugin structure
  style/             # [knowledge] Working conventions
agents/              # Specialized subagents
.claude-plugin/      # Plugin manifest (plugin.json)
specs/               # Feature specifications
docs/                # Documentation
  release/           # Release notes per version
```

## Session End Checklist

Before ending a session:

```bash
git status            # Check uncommitted changes
git add <files>       # Stage changes
git commit -m "..."   # Commit code
git push              # Push to remote
```

If beads is configured, also run `bd sync --from-main` before committing.

Work is not complete until `git push` succeeds.

## Development

To work on Trellis itself:

```bash
claude --plugin-dir /path/to/trellis
```

Skills are markdown files in `skills/<skill-name>/SKILL.md` and subagents are defined in `agents/`. Changes require restart to take effect.
