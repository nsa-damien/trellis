---
name: architecture
description: Trellis plugin structure, data flow, and integration rules
---

# Trellis Architecture

Trellis is an AI-native development workflow plugin for Claude Code. It provides a two-command lifecycle: **scope** (branch + build + verify + PR) and **release** (merge + tag + publish). After a single user approval, Trellis executes autonomously -- dispatching specialized agents in parallel, running verification, and committing incrementally.

## Data Flow

```
User intent (natural language)
    |
    v
/trellis:scope
    |-- creates branch
    |-- /trellis:implement (autonomous)
    |       |-- specialized agents (parallel)
    |       |-- verification (tests, lint, visual)
    |       |-- incremental commits
    |-- push + PR
    |
    v
/trellis:release
    |-- merge PR
    |-- tag version
    |-- GitHub release
```

## Plugin Structure

```
skills/              # Skill definitions (*/SKILL.md)
  scope/             # Primary entry point -- branch, build, verify, PR
  implement/         # Autonomous build engine
  status/            # Project health + ready work
  init/              # First-time setup
  codemap/           # Codebase navigation map
  push/              # Manual commit + push
  pr/                # Manual PR creation
  release/           # Merge, tag, publish
  architecture/      # [knowledge] Plugin structure and data flow
  style/             # [knowledge] Working conventions
agents/              # Specialized subagents
  backend-architect  # System design and API architecture
  frontend-developer # UI components and client-side logic
  database-architect # Schema design and migrations
  golang-pro         # Go implementation
  python-pro         # Python implementation
  typescript-pro     # TypeScript implementation
  general-purpose    # Cross-cutting and misc tasks
  code-reviewer      # Review and quality checks
  test-runner        # Test execution and verification
.claude-plugin/      # Plugin manifest (plugin.json)
```

## Core Invariants

These rules must be preserved across all skills and agents:

1. **Scope creates branches; release merges them.** These are the only two user-facing lifecycle commands. Everything else is either an implementation detail or a manual escape hatch.

2. **Implement runs autonomously after one approval.** Once the user confirms the scope, no further prompts should interrupt execution. Errors are self-corrected or reported at the end.

3. **Agents are dispatched in parallel where possible.** Independent work units run concurrently via the Task tool. Dependent work is sequenced automatically.

4. **Verification is layered and optional.** The verification sequence is: tests, then lint, then visual. Each layer runs only if applicable to the project. Failure at any layer triggers self-correction before moving on.

5. **Self-correction is bounded.** A failing step may be retried up to 3 times. After that, the failure is reported to the user rather than looping indefinitely.

6. **Beads is optional.** When the `bd` CLI is available, Trellis uses it for session recovery and dependency tracking. When unavailable, Trellis skips beads operations silently and relies on git commits alone.

7. **Commits are incremental.** Each logical work unit produces its own commit. Do not batch all changes into a single commit at the end.

## Component Roles

### Skills

Skills are either user-invocable commands or knowledge resources referenced by other skills and agents.

| Skill | Type | Purpose |
|-------|------|---------|
| `scope` | command | Branch, build, verify, PR -- the primary workflow |
| `implement` | command | Autonomous build engine (usually called by scope) |
| `status` | command | Project health overview and ready work |
| `init` | command | First-time project setup |
| `codemap` | command | Generate/update CODEMAP.yaml for navigation |
| `push` | command | Manual commit and push |
| `pr` | command | Manual PR creation |
| `release` | command | Merge, tag, publish |
| `architecture` | knowledge | Plugin structure and data flow (this file) |
| `style` | knowledge | Working conventions for git, commits, safety |

### Agents

Agents are specialized executors. Implementation agents are dispatched by the implement skill; utility agents serve verification and review roles outside the implementation dispatch.

| Agent | Domain | Role |
|-------|--------|------|
| `backend-architect` | System design, API architecture, service structure | Implementation |
| `frontend-developer` | UI components, client-side logic, styling | Implementation |
| `database-architect` | Schema design, migrations, query optimization | Implementation |
| `golang-pro` | Go implementation following Go idioms | Implementation |
| `python-pro` | Python implementation following Python conventions | Implementation |
| `typescript-pro` | TypeScript implementation with type safety | Implementation |
| `general-purpose` | Cross-cutting changes, config, infrastructure | Implementation |
| `code-reviewer` | Code review, quality checks, style enforcement | Utility |
| `test-runner` | Test execution, coverage, verification | Utility |

### Beads (Optional)

When the `bd` CLI is available, Trellis uses it for persistent state:

```bash
bd create --title="..." --type=task   # Track scope as issue
bd update <id> --status=in_progress   # Mark progress
bd close <id>                         # Complete work
bd ready                              # Find unblocked work
bd sync                               # Persist state to git
```

When beads is unavailable, Trellis proceeds without it. No errors are raised. Git commits serve as the sole record of progress.

## Skill Interactions

### Primary Workflow (scope + release)

```
/trellis:scope "add user authentication"
    |
    |-- git checkout -b feat/user-authentication
    |-- /trellis:implement
    |       |-- dispatch: typescript-pro (API routes)
    |       |-- dispatch: database-architect (schema)
    |       |-- dispatch: frontend-developer (login form)
    |       |-- verify: run tests + lint (shell)
    |       |-- commit per work unit
    |-- git push + create PR
    |
    v
/trellis:release
    |-- merge PR
    |-- git tag v1.2.0
    |-- GitHub release with notes
```

### Manual Escape Hatches

| Skill | When to Use |
|-------|-------------|
| `push` | Need to commit and push without a full scope cycle |
| `pr` | Need a PR without going through scope |
| `status` | Check project state, find ready work, review health |
| `init` | First time setting up Trellis in a project |
| `codemap` | Regenerate navigation map after structural changes |

### Skill Dependencies

| Skill | Requires | Produces |
|-------|----------|----------|
| `scope` | User intent | Branch, code changes, PR |
| `implement` | Branch, work description | Code changes, commits |
| `status` | Git repo | Health report |
| `init` | Git repo | Plugin configuration |
| `codemap` | Source files | CODEMAP.yaml |
| `push` | Staged/unstaged changes | Commits, remote push |
| `pr` | Remote branch | Pull request |
| `release` | PR (or creates one) | Merge, tag, GitHub release |

## Session Management

### Starting a Session

- `/trellis:status` -- shows branch state, uncommitted changes, and project health
- `/trellis:init` -- first-time setup if the project has not been configured
- If beads is available: `bd ready` shows unblocked work; `bd list --status=in_progress` shows interrupted work

### During a Session

Implement runs autonomously. Agents are dispatched, verification runs, and commits are made without user intervention. The user is only interrupted if:
- A verification failure cannot be self-corrected after 3 retries
- A destructive operation requires confirmation (see style knowledge skill)

### Ending a Session

Code is committed and pushed by scope automatically. For manual sessions:

```bash
git status            # Check for uncommitted changes
git add <files>       # Stage changes
git commit -m "..."   # Commit
git push              # Push to remote
```

If beads is available: `bd sync` to persist issue state.

**Work is not complete until `git push` succeeds.**

### Session Recovery

If a session is interrupted mid-work:
1. `/trellis:status` -- shows branch state and uncommitted changes
2. `git log --oneline -10` -- shows recent commits on the branch
3. If beads is available: `bd list --status=in_progress` -- shows interrupted work
4. Resume with `/trellis:implement` or manual work

## Error Handling

### Common Issues

| Error | Cause | Resolution |
|-------|-------|------------|
| Branch already exists | Re-scoping same work | Delete branch or use a different name |
| Push rejected | Remote has diverged | Pull and rebase, then push |
| Agent task failed | Implementation error | Check error output, retry or fix manually |
| Verification failed 3x | Persistent test/lint failure | Report to user with details for manual fix |
| `bd` command not found | Beads not installed | Ignore; Trellis works without beads |
| PR creation failed | No remote, auth issue | Check `gh auth status`, verify remote exists |
| Merge conflict | Parallel branch changes | Resolve conflicts manually, then continue |

### Recovery Steps

For most failures, the recovery path is:

1. Check `/trellis:status` for current state
2. Review git log and diff to understand what completed
3. Fix the issue (resolve conflict, fix test, etc.)
4. Resume with `/trellis:implement` or `/trellis:push`
