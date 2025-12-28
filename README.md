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

```bash
git clone https://github.com/nsa-damien/trellis.git
cd trellis
./install.sh           # User-level (all projects)
./install.sh --project # Project-level (single project)
```

## Commands

| Command | Purpose |
|---------|---------|
| `/trellis.import` | Import tasks.md into beads |
| `/trellis.implement` | Execute with dependency-aware ordering |
| `/trellis.sync` | Reconcile beads ↔ tasks.md |
| `/trellis.ready` | Show unblocked tasks |
| `/trellis.status` | Project health overview |

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

MIT - See [LICENSE](LICENSE)
