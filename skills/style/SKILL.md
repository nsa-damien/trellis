---
name: style
description: Trellis working conventions -- git, commits, safety, and code discipline
user-invocable: false
---

# Trellis Style Guide

Working conventions for Trellis-managed projects. These guidelines ensure consistency, prevent common mistakes, and define safety boundaries.

## Git Conventions

### Commit Messages

Follow conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` -- New feature
- `fix` -- Bug fix
- `docs` -- Documentation only
- `refactor` -- Code change that neither fixes nor adds
- `test` -- Adding or updating tests
- `chore` -- Maintenance tasks

Examples:
```
feat(auth): add OAuth2 login flow
fix(api): handle null response from external service
docs(readme): update installation instructions
refactor(router): extract middleware into separate module
```

### Branch Naming

```
type/short-description
```

Types mirror commit types: `feat/`, `fix/`, `refactor/`, `chore/`, `docs/`

Examples:
- `feat/user-authentication`
- `fix/login-timeout`
- `refactor/extract-middleware`
- `chore/update-dependencies`

### Commit Frequency

- **Commit working states** -- Never commit broken code
- **Atomic commits** -- Each commit is one logical change
- **Commit before switching tasks** -- Preserve work state
- **Incremental during implement** -- Each work unit gets its own commit, not one big commit at the end

## Safety Practices

### Confirmation Required

Always prompt the user before:
- `git push` -- Especially to main/master
- `git push --force` -- Warn strongly, require explicit confirmation
- Release creation -- Tag + GitHub release
- PR merge -- Permanent action
- Branch deletion -- Destructive

### Dry-Run Support

For risky operations, offer `--dry-run` where applicable:
```bash
/trellis:release --dry-run   # Preview release without creating
```

### Never Auto-Execute

These require an explicit user request:
- Force push (`--force`, `--force-with-lease`)
- Branch deletion
- Release/tag creation
- PR merge
- Credential or secret handling

### Error Recovery

When operations fail:
1. Report the specific error with context
2. Suggest concrete recovery steps
3. Do not retry automatically without user consent

## Code Discipline

### Stay on Task

- **Do not fix unrelated issues** -- Even if you notice them
- **Note discovered work** -- Log it as a new beads issue (`bd create`) if beads is available, or document it in a comment/TODO
- **Minimal changes** -- The smallest diff that accomplishes the goal
- **No opportunistic refactoring** -- Do not "improve" code that is not part of the current task

### Documentation

- Update docs when behavior changes
- Keep README current with new features
- Add inline comments only where logic is non-obvious
- Do not generate documentation files unless explicitly requested

## Markdown Conventions

### Minimal Edits

When editing markdown files:
- **Change only what you must** -- Do not reformat unrelated sections
- **Preserve existing style** -- Match surrounding indentation, heading levels, and formatting
- **No whitespace normalization** -- Do not fix trailing spaces or line endings in lines you are not changing

## CHANGELOG Maintenance

### When to Update

Update `CHANGELOG.md` for:
- New features
- Bug fixes
- Breaking changes
- Deprecations
- Security fixes

Do not update for:
- Internal refactoring
- Test additions or changes
- CI/CD pipeline changes
- Documentation-only changes

### Format

Follow Keep a Changelog format:

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

## Session Management

### Before Ending a Session

```bash
git status            # Check for uncommitted changes
git add <files>       # Stage changes
git commit -m "..."   # Commit
git push              # Push to remote
```

If beads is available:
```bash
bd sync               # Persist beads state to git
```

**Work is not complete until `git push` succeeds.**

### Ephemeral Branches

On ephemeral feature branches, if beads is available:
```bash
bd sync --from-main   # Sync beads state from main before starting
```

## Error Messages

### Be Specific and Actionable

Bad:
```
Error: Operation failed.
```

Good:
```
Push rejected: remote branch has diverged.
Run `git pull --rebase` to incorporate remote changes, then push again.
```

### Always Include Next Steps

Every error message should tell the user what to do next. If the recovery path is ambiguous, present options:

```
Verification failed after 3 retries: 2 tests failing in auth.test.ts

Options:
  1. Review failures: npm test -- --filter auth
  2. Skip verification: /trellis:push (commits without verification)
  3. Abort: git checkout main
```
