# Trellis

> A Claude Code plugin for structured software development — from planning through implementation, tracking, and release.

## What It Does

Trellis gives Claude Code a complete development workflow through skills and specialized agents:

- **Plan** — Interactive PRD creation, epic decomposition, spec-driven task generation
- **Track** — Import tasks into [beads](https://github.com/steveyegge/beads) for dependency-aware execution and progress tracking
- **Build** — Parallel agent dispatch with specialized agents (frontend, backend, database, Go, Python, TypeScript)
- **Ship** — Commit, push, PR creation, and tagged releases with changelogs

## Installation

**Prerequisites:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [beads](https://github.com/steveyegge/beads)

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

| Skill | Purpose |
|-------|---------|
| `/trellis:prd` | Interactive PRD development through structured discovery |
| `/trellis:epics` | Break PRD into sequenced, dependency-aware epics |
| `/trellis:import` | Import tasks.md into beads with hierarchy and dependencies |
| `/trellis:implement` | Execute tasks with parallel agents and dependency ordering |
| `/trellis:sync` | Bidirectional sync between beads and tasks.md |
| `/trellis:ready` | Show unblocked tasks ready to work |
| `/trellis:status` | Project health and progress overview |
| `/trellis:codemap` | Generate CODEMAP.yaml for LLM code navigation |
| `/trellis:test-plan` | Generate test plan and executable test files |
| `/trellis:push` | Commit and push with changelog updates |
| `/trellis:pr` | Create pull request for current branch |
| `/trellis:release` | Create release with tag, notes, and GitHub release |

## Agents

Trellis includes specialized agents that `/trellis:implement` routes tasks to automatically:

| Agent | Focus |
|-------|-------|
| `backend-architect` | APIs, services, middleware |
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
# 1. Create a PRD interactively
/trellis:prd

# 2. Break into epics
/trellis:epics

# 3. Generate tasks and import to beads
/speckit.tasks
/trellis:import

# 4. Implement with parallel agents
/trellis:implement

# 5. Ship it
/trellis:push
/trellis:pr
/trellis:release
```

## Development

```bash
git clone https://github.com/NorthShoreAutomation/trellis.git
claude --plugin-dir /path/to/trellis
```

Changes to skills and agents take effect on restart.

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — Data flow and component roles
- [Usage Guide](USAGE.md) — Step-by-step workflow walkthrough
- [Changelog](CHANGELOG.md) — Version history

## License

MIT — See [LICENSE](LICENSE)
