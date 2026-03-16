# Trellis

> An AI-native workflow framework for Claude Code — development, client deliverables, documentation, and domain knowledge in one plugin.

## What It Does

Trellis is North Shore Automation's framework for working with AI. It started as a development workflow plugin and has grown into a comprehensive set of skills covering the full project lifecycle — from pre-sales discovery through implementation to delivery.

### Development Workflow

Two-command lifecycle: describe what you want, approve the approach, walk away.

1. **`/trellis:scope "description"`** — Creates a branch, proposes an approach, implements with parallel agents, tests, commits, pushes, and opens a PR.
2. **`/trellis:release`** — Merges the PR, tags, and publishes a GitHub release.

### Client Deliverables

Interview-driven document generators that produce ready-to-review Google Docs:

- **SOW Generators** — Statements of Work for Iconik, CatDV, Dhub OTT, and media migration projects. Template-driven with conditional logic.
- **Project Requirements** — Client-facing requirements documents for approval before SOW/pricing phase.
- **Meeting Summaries** — Professional recap emails with Calendar integration for attendee lookup.

### Documentation & Knowledge

- **Repo Docs Generator** — Three-document package (Technical Overview, Deployment Guide, User Guide) from any codebase.
- **Hybrid Search** — Expert guidance for PostgreSQL + OpenSearch systems over transcribed media.
- **Library Assistant** — Design guide for conversational media library assistants.

## Installation

**Prerequisites:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

**Optional:** [beads](https://github.com/steveyegge/beads) for session recovery and dependency tracking

```bash
# Add the marketplace and install
/plugin marketplace add NorthShoreAutomation/trellis
/plugin install trellis@NorthShoreAutomation/trellis
```

Or add to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "nsa-trellis": {
      "source": {
        "source": "github",
        "repo": "NorthShoreAutomation/trellis"
      }
    }
  },
  "enabledPlugins": {
    "trellis@nsa-trellis": true
  }
}
```

## Skills

### Development Workflow
| Skill | Purpose |
|-------|---------|
| `/trellis:scope` | **Start new work** — branch + implement + push + PR |
| `/trellis:release` | **Ship it** — merge + tag + GitHub release |
| `/trellis:implement` | Autonomous build engine (also available standalone) |
| `/trellis:status` | Project health, ready work, branch state |
| `/trellis:ideas` | Capture, track, and prioritize project ideas |

### Client Deliverables
| Skill | Purpose |
|-------|---------|
| `/sow-iconik` | **Iconik Up and Running SOW** — template-driven interview + conditional logic |
| `/sow-migration` | **Migration SOWs** — MAM and Avid Interplay migration |
| `/sow-catdv` | **CatDV Up and Running SOW** *(placeholder)* |
| `/sow-catdv-upgrade` | **CatDV Upgrade/Cloud Migration SOW** *(placeholder)* |
| `/sow-dhub` | **Dhub OTT SOW** *(placeholder)* |
| `/trellis:project-requirements` | Client-facing requirements document for pre-SOW approval |
| `/trellis:meeting-summary` | Meeting recap emails with Calendar attendee lookup |

### Documentation & Knowledge
| Skill | Purpose |
|-------|---------|
| `/trellis:repo-docs-generator` | Three-document package from any codebase |
| `/trellis:codemap` | Generate/update CODEMAP.yaml for LLM code navigation |
| `/trellis:hybrid-search` | Hybrid search systems (PostgreSQL + OpenSearch + Cohere) |
| `/trellis:library-assistant` | Conversational media library assistant design |

### Session Management
| Skill | Purpose |
|-------|---------|
| `/trellis:context-handoff` | Save session context to `handoff.md` |
| `/trellis:context-resume` | Resume from a `handoff.md` with drift detection |

### Escape Hatches
| Skill | Purpose |
|-------|---------|
| `/trellis:push` | Manual commit and push |
| `/trellis:pr` | Manual PR creation |

## Agents

Specialized agents dispatched by `/trellis:implement` based on task type:

| Agent | Focus |
|-------|-------|
| `backend-architect` | APIs, services, middleware, error handling |
| `frontend-developer` | UI components, accessibility, responsive design |
| `database-architect` | Schemas, migrations, query optimization |
| `golang-pro` | Idiomatic Go with concurrency patterns |
| `python-pro` | Python with type hints, pytest, async |
| `typescript-pro` | TypeScript with strict types and modern patterns |
| `general-purpose` | Config, refactoring, cross-cutting tasks |
| `code-reviewer` | Read-only review for correctness and safety |
| `test-runner` | Test execution and failure reporting |

## Quick Start

```bash
# Development workflow
/trellis:codemap                              # Map your codebase (recommended first step)
/trellis:scope "add a health check endpoint"  # Build something
/trellis:release                              # Ship it

# Generate a Statement of Work
/sow-iconik                                   # Start the Iconik SOW interview

# Document a repository
/trellis:repo-docs-generator                  # Three-document package
```

## Development

```bash
git clone https://github.com/NorthShoreAutomation/trellis.git
claude --plugin-dir /path/to/trellis
```

Skills are markdown files in `skills/<skill-name>/SKILL.md` and agents are defined in `agents/`. Changes require restart to take effect.

## Documentation

- [Changelog](CHANGELOG.md) — Version history
- [Release Notes](docs/release/) — Per-version details

## License

MIT — See [LICENSE](LICENSE)
