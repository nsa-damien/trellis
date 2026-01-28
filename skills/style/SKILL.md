---
name: style
description: Trellis working conventions (sync, commits, safety, formatting)
user-invocable: false
---

# Trellis Style Guide

Conventions for working with Trellis-managed projects. These guidelines ensure consistency and prevent common mistakes.

## Beads-First Workflow

### Source of Truth

- **Beads owns task state** — Never update tasks.md checkboxes directly; use `bd close <id>` then `/trellis:sync`
- **Check before acting** — Run `bd ready` to see what's available before picking work
- **Resume via beads** — Use `bd list --status=in_progress` to find interrupted work

### Status Updates

```bash
# Correct workflow
bd update <id> --status=in_progress  # Claim task
# ... do work ...
bd close <id>                         # Complete task
/trellis:sync                         # Update tasks.md

# Incorrect - don't do this
# Manually checking [X] in tasks.md
```

### Dependency Respect

- Never work on blocked tasks — Check `bd blocked` if confused
- Complete dependencies first — `bd show <id>` shows blockers
- Don't skip ahead — Follow `bd ready` ordering

## Markdown Conventions

### Minimal Edits

When editing markdown files:
- **Change only what you must** — Don't reformat unrelated sections
- **Preserve existing style** — Match surrounding indentation and formatting
- **Checkbox edits only for sync** — `/trellis:sync` should only toggle `[ ]` ↔ `[X]`

### tasks.md Formatting

```markdown
## Phase 1: Setup
- [ ] 1.1 First task
- [ ] 1.2 Second task (depends on 1.1)
- [P] 1.3 Parallel task (can run anytime)

## Phase 2: Implementation
- [ ] 2.1 Blocked until Phase 1 complete
```

- Use `[P]` prefix for parallel tasks
- Keep task descriptions concise (one line)
- Don't add extra metadata — beads tracks details

### Preserving Structure

When `/trellis:sync` updates tasks.md:
- Only checkbox state changes
- No line reordering
- No whitespace normalization
- No comment additions

## Git Conventions

### Commit Messages

Follow conventional commits:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation only
- `refactor` — Code change that neither fixes nor adds
- `test` — Adding or updating tests
- `chore` — Maintenance tasks

Examples:
```bash
feat(auth): add OAuth2 login flow
fix(api): handle null response from external service
docs(readme): update installation instructions
```

### Branch Naming

```
type/short-description
```

Examples:
- `feat/user-authentication`
- `fix/login-timeout`
- `docs/api-reference`

### Commit Frequency

- **Commit working states** — Don't commit broken code
- **Atomic commits** — Each commit is one logical change
- **Commit before switching tasks** — Preserve work state

## Safety Practices

### Confirmation Required

Always prompt user before:
- `git push` — Especially to main/master
- `git push --force` — Warn strongly, require explicit confirmation
- Release creation — Tag + GitHub release
- PR merge — Permanent action
- Destructive beads operations — Closing epics, bulk updates

### Dry-Run First

For risky operations, offer `--dry-run`:
```bash
/trellis:import --dry-run    # Preview what would be imported
/trellis:sync --dry-run      # Show what would change
/trellis:release --dry-run   # Preview release without creating
```

### Never Auto-Execute

These require explicit user request:
- Force push (`--force`, `--force-with-lease`)
- Branch deletion
- Release/tag creation
- PR merge
- Credential/secret handling

### Error Recovery

When operations fail:
1. Report the specific error
2. Suggest recovery steps
3. Don't retry automatically without user consent

## Session Management

### Starting Work

```bash
bd ready                           # What's available?
bd list --status=in_progress       # Any interrupted work?
bd show <id>                       # Review task details
bd update <id> --status=in_progress  # Claim it
```

### During Work

- Keep changes focused on the current task
- Don't refactor unrelated code
- Commit incrementally for complex tasks

### Completing Work

```bash
# For each completed task
bd close <id>

# Then sync and push
/trellis:sync
git add <files>
git commit -m "feat(scope): description"
git push
```

### Session Checklist

Before saying "done":
```
[ ] All tasks marked closed in beads
[ ] /trellis:sync run (tasks.md updated)
[ ] git status clean (all changes committed)
[ ] git push successful
```

**Work is not complete until `git push` succeeds.**

## Code Conventions

### Scope Discipline

- **Stay on task** — Don't fix unrelated issues you notice
- **Note, don't fix** — Log discovered issues as new beads tasks
- **Minimal changes** — Smallest diff that accomplishes the goal

### Creating New Work

When you discover additional work needed:
```bash
bd create --title="Fix discovered issue" --type=bug --priority=2
```

Don't:
- Silently expand scope
- Fix "while you're in there"
- Refactor without explicit request

### Documentation

- Update docs for changed behavior
- Keep README current
- Add inline comments only where non-obvious

## CHANGELOG Maintenance

### When to Update

Update `CHANGELOG.md` for:
- New features
- Bug fixes
- Breaking changes
- Deprecations
- Security fixes

Don't update for:
- Internal refactoring
- Test changes
- CI/CD changes
- Documentation-only changes

### Format

```markdown
## [Unreleased]

### Added
- New feature description

### Changed
- Modified behavior description

### Fixed
- Bug fix description

### Removed
- Removed feature description
```

## Beads ID Conventions

### ID Format

```
proj-XXXX       # Root epic (feature)
proj-XXXX.N     # Phase epic
proj-XXXX.N.M   # Task issue
```

### Referencing IDs

In commit messages:
```bash
git commit -m "feat(auth): implement login [proj-a1b2.1.3]"
```

In PR descriptions:
```markdown
## Related Issues
- proj-a1b2.1.3: Implement login form
- proj-a1b2.1.4: Add validation
```

## Error Messages

### User-Facing Errors

Be specific and actionable:
```
❌ "Error occurred"
✅ "Database locked. Another beads process may be running. Try: bd sync --status"
```

### Recovery Guidance

Always include next steps:
```
Error: No beads-mapping.json found in specs/my-feature/

This feature hasn't been imported yet. Run:
  /trellis:import specs/my-feature/tasks.md
```
