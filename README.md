# Trellis

> Bridge [spec-kit](https://github.com/github/spec-kit) planning with [beads](https://github.com/steveyegge/beads) issue tracking for Claude Code.

## Why Trellis?

spec-kit generates excellent task breakdowns in `tasks.md`, but checkbox-based tracking lacks dependency awareness and session recovery. Trellis imports tasks into beads for intelligent execution ordering, then keeps both in sync.

## Workflow

```
spec-kit                    Trellis
─────────                   ───────
/speckit.spec → spec.md
/speckit.plan → plan.md
/speckit.tasks → tasks.md ──→ /trellis.import ──→ beads issues
                            /trellis.implement ──→ dependency-aware execution
                            /trellis.sync ──→ bidirectional sync
```

## Installation

**Prerequisites:** [Claude Code](https://claude.ai/code), [beads](https://github.com/steveyegge/beads), [spec-kit](https://github.com/github/spec-kit)

### From GitHub (Private Repository)

Since this is a private repository, you need to configure authentication first:

**1. Create a GitHub Personal Access Token:**
- Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
- Click "Generate new token (classic)"
- Give it a descriptive name (e.g., "Claude Code plugins")
- Select the `repo` scope (required for private repository access)
- Click "Generate token" and copy the token

**2. Set the environment variable:**

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export GITHUB_TOKEN=ghp_your_token_here
```

**3. Add the marketplace and install:**

```bash
# Add the repository as a marketplace source
/plugin marketplace add NorthShoreAutomation/trellis

# Install the plugin
/plugin install trellis@NorthShoreAutomation/trellis
```

### Alternative: Settings File

Add to `~/.claude/settings.json`:

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

## Development

For contributors developing Trellis locally:

```bash
git clone https://github.com/NorthShoreAutomation/trellis.git
claude --plugin-dir /path/to/trellis
```

The `--plugin-dir` flag loads the plugin for that session. Changes to skills/agents are reflected on restart.

## Migration

If upgrading from older installs that copied command files into `~/.claude/commands/` or `.claude/commands/`, remove those copies and install via plugin.

## Commands

| Command | Purpose |
|---------|---------|
| `/trellis.import` | Import tasks.md into beads |
| `/trellis.implement` | Execute with dependency-aware ordering |
| `/trellis.sync` | Reconcile beads ↔ tasks.md |
| `/trellis.ready` | Show unblocked tasks |
| `/trellis.status` | Project health overview |
| `/trellis.prd` | Interactive PRD development |
| `/trellis.epics` | Break PRD into sequenced epics |
| `/trellis.test-plan` | Generate test plan documentation |
| `/trellis.push` | Commit and push with changelog |
| `/trellis.release` | Create release from PR |

Run any command with `--help` for options (e.g., `--dry-run`, `--force`).

## Quick Start

```bash
# 1. Generate tasks with spec-kit
/speckit.tasks

# 2. Import to beads
/trellis.import

# 3. Execute with tracking
/trellis.implement

# 4. Check progress anytime
/trellis.status
bd ready
bd stats
```

## How It Maps

| spec-kit | beads | Notes |
|----------|-------|-------|
| Feature | Root Epic | Parent of all phases |
| Phase | Epic | Groups related tasks |
| Task | Issue | Actual work item |
| Sequential task | `blocks` dependency | Enforces order |
| `[P]` parallel marker | No dependency | Can run anytime |

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - How the integration works
- [Changelog](CHANGELOG.md) - Version history

## License

Proprietary - See [LICENSE](LICENSE)
