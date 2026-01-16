# Contracts

This feature modifies a Claude Code command file. There are no API contracts to define.

The "contract" for this feature is the command's interface (flags and behavior), which is documented in:
- The command file itself (`commands/trellis.implement.md`)
- The spec (`spec.md`)
- The quickstart (`quickstart.md`)

## Command Interface Contract

### Invocation
```
/trellis.implement [options]
```

### Options (unchanged from current)
- `--dry-run`: Show execution plan without changes
- `--task T001`: Execute specific task only
- `--phase N`: Execute phase N only
- `--continue`: Resume from previous session
- `--no-sync`: Don't sync to tasks.md (beads only)
- `--verbose`: Show all bd commands
- `--force`: Continue past failures without prompting
- `--parallel-limit N`: Max concurrent agents per batch (default: 3)
- `--no-parallel`: Force sequential execution (parallel-limit=1)

### Behavioral Contract (enhanced)
1. Continuous execution until all beads complete or blocker encountered
2. Fresh agent per bead (no context sharing)
3. Intelligent agent routing based on task characteristics
4. Parallel execution of non-conflicting beads
5. Actionable blocker messages when pausing required
