# Trellis

> An AI-native development workflow plugin for Claude Code — describe what you want, approve the approach, walk away.

## What It Does

Trellis gives Claude Code an autonomous development workflow. Two commands:

1. **`/trellis:scope "description"`** — Creates a branch, proposes an approach, implements with parallel agents, tests, commits, pushes, and opens a PR. One approval, then hands-off.
2. **`/trellis:release`** — Merges the PR, tags, and publishes a GitHub release.

Everything else is supporting infrastructure or manual escape hatches.

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

### Primary Workflow
| Skill | Purpose |
|-------|---------|
| `/trellis:scope` | **Start new work** — branch + implement + push + PR |
| `/trellis:release` | **Ship it** — merge + tag + GitHub release |

### Supporting
| Skill | Purpose |
|-------|---------|
| `/trellis:implement` | Autonomous build engine (also available standalone) |
| `/trellis:status` | Project health, ready work, branch state |
| `/trellis:codemap` | Generate/update CODEMAP.yaml for LLM code navigation |

### Knowledge
| Skill | Purpose |
|-------|---------|
| `/trellis:hybrid-search` | Hybrid search systems (PostgreSQL + OpenSearch + Cohere embeddings) |
| `/trellis:library-assistant` | Conversational media library assistant design |

### Escape Hatches
| Skill | Purpose |
|-------|---------|
| `/trellis:push` | Manual commit and push |
| `/trellis:pr` | Manual PR creation |

## Agents

Specialized agents that `/trellis:implement` dispatches in parallel:

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
# 1. Map your codebase (recommended for new projects)
/trellis:codemap

# 2. Build something
/trellis:scope "add a health check endpoint"

# 3. Ship it
/trellis:release
```

## Development

```bash
git clone https://github.com/NorthShoreAutomation/trellis.git
claude --plugin-dir /path/to/trellis
```

Changes to skills and agents take effect on restart.

## Documentation

- [Changelog](CHANGELOG.md) — Version history

## License

MIT — See [LICENSE](LICENSE)
