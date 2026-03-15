# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Trellis is North Shore Automation's AI-native workflow framework for Claude Code. It covers the full project lifecycle — development, client deliverables, documentation, and domain knowledge — all as skills and agents in a single plugin.

**Development workflow:**
```
/trellis:scope "description"  →  /trellis:release
         ↓                              ↓
  branch+implement+push+PR      merge+tag+publish
```

**Client deliverables:** SOW generators, project requirements, meeting summaries — all interview-driven, producing Google Docs.

**Documentation:** Repo docs generator, codemap, knowledge skills for hybrid search and library assistant design.

## Skills

### Development Workflow
| Skill | Purpose |
|-------|---------|
| `/trellis:scope` | **Start new work** — branch + implement + push + PR |
| `/trellis:release` | **Ship it** — merge + tag + GitHub release |
| `/trellis:implement` | Autonomous build engine (used by scope, or standalone for additional work) |
| `/trellis:status` | Project health, ready work, branch state |

### Client Deliverables
| Skill | Purpose |
|-------|---------|
| `/sow-iconik` | **Iconik Up and Running SOW** — template-driven interview + tag processing |
| `/sow-migration` | **Migration SOWs** — MAM and Avid Interplay migration |
| `/sow-catdv` | **CatDV Up and Running SOW** — placeholder |
| `/sow-catdv-upgrade` | **CatDV Upgrade/Cloud Migration SOW** — placeholder |
| `/sow-dhub` | **Dhub OTT SOW** — placeholder |
| `/trellis:project-requirements` | Client-facing requirements document for pre-SOW approval |
| `/trellis:meeting-summary` | Meeting recap emails with Calendar attendee lookup |

### Documentation & Knowledge
| Skill | Purpose |
|-------|---------|
| `/trellis:repo-docs-generator` | Three-document package from any codebase |
| `/trellis:codemap` | Generate/update CODEMAP.yaml for LLM navigation (recommended starting point) |
| `/trellis:hybrid-search` | Hybrid search systems (PostgreSQL + OpenSearch + Cohere embeddings) |
| `/trellis:library-assistant` | Conversational media library assistant design (RAG, prompts, patterns) |

### Session Management
| Skill | Purpose |
|-------|---------|
| `/trellis:context-handoff` | Generate handoff document for session continuity |
| `/trellis:context-resume` | Resume work from a handoff document |

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
skills/                        # Trellis skills (*/SKILL.md)
  scope/                       # Primary entry point — branch + build + PR
  implement/                   # Autonomous build engine
  release/                     # Merge, tag, publish
  status/                      # Project health + ready work
  codemap/                     # Codebase navigation map
  context-handoff/             # Session continuity handoff generator
  context-resume/              # Resume from handoff document
  push/                        # Manual commit+push
  pr/                          # Manual PR creation
  iconik-sow-generator/       # Iconik Up and Running SOW
  migration-sow-generator/    # MAM and Avid Interplay migration SOW
  catdv-sow-generator/        # CatDV Up and Running SOW (placeholder)
  catdv-upgrade-sow-generator/ # CatDV Upgrade SOW (placeholder)
  dhub-ott-sow-generator/     # Dhub OTT SOW (placeholder)
  project-requirements/       # Client-facing requirements document
  meeting-summary/             # Meeting recap email generator
  repo-docs-generator/        # Three-document package generator
  hybrid-search/               # [knowledge] Hybrid search systems
  library-assistant/           # [knowledge] Conversational library assistant
  architecture/                # [knowledge] Plugin structure
  style/                       # [knowledge] Working conventions
agents/                        # Specialized subagents (9 total)
.claude-plugin/                # Plugin manifest (plugin.json)
specs/                         # Feature specifications
docs/                          # Documentation
  release/                     # Release notes per version
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
