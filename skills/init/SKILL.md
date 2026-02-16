---
name: init
description: First-time project setup — detect project type, configure beads, set conventions
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Instructions

### 1. Detect Project Type

Scan the repository root for project markers and report what was detected:

| Language | Markers |
|----------|---------|
| Go | `go.mod`, `*.go` files |
| TypeScript/JavaScript | `package.json`, `tsconfig.json` |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt` |
| Rust | `Cargo.toml` |

- If multiple languages are detected, identify the primary language (the one with the most source files or the root-level build config).
- Report all detected languages and which is primary.

### 2. Check Beads

1. Check if `bd` command is available: `command -v bd`
2. Check if `.beads/` directory exists in the repository root

| State | Action |
|-------|--------|
| `bd` available + `.beads/` exists | Report: "Beads: initialized and ready" |
| `bd` available + no `.beads/` | Offer to run `bd init` to initialize |
| `bd` not available | Inform user: beads is optional, explain what it provides (session recovery, dependency tracking, persistent state across sessions), and how to install it |

### 3. Detect Existing Tooling

Scan for configuration files and report what was found:

| Category | Look for |
|----------|----------|
| Test framework | `jest.config.*`, `vitest.config.*`, `pytest.ini`, `pyproject.toml` (pytest section), `*_test.go` patterns, `Cargo.toml` (test section) |
| Linter | `.eslintrc.*`, `eslint.config.*`, `ruff.toml`, `pyproject.toml` (ruff section), `.golangci.yml`, `clippy.toml` |
| CI | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/` |
| Formatter | `.prettierrc*`, `rustfmt.toml`, `pyproject.toml` (black/ruff format section) |

Report each category as either the detected tool name or "none detected".

### 4. Check Plugin Installation

1. Verify trellis is installed as a plugin (check `.claude-plugin/` directory exists in the repo or that trellis skills are accessible)
2. Check if `CLAUDE.md` exists in the repository root
3. If `CLAUDE.md` exists, check whether it references trellis commands
4. Suggest updates if `CLAUDE.md` is missing or does not reference trellis

### 5. Set Conventions

Present the conventions that trellis uses automatically:

- **Commit messages**: Conventional commits format (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`)
- **Branch naming**: `feat/`, `fix/`, `refactor/`, `chore/` prefixes with kebab-case description

These are informational only. Trellis applies them automatically via `/trellis:scope`.

### 6. Report Summary

Display a completion summary:

```
═══════════════════════════════════════════════════════════
TRELLIS INITIALIZED
═══════════════════════════════════════════════════════════

Project: [name from package.json/go.mod/pyproject.toml/Cargo.toml/directory name]
Type: [Go/TypeScript/Python/Rust/Multi-language]

Tooling detected:
├── Tests: [framework or "none detected"]
├── Linter: [tool or "none detected"]
├── CI: [provider or "none detected"]
└── Beads: [initialized/available/not installed]

Ready to use:
• /trellis:scope "description"  — Start building
• /trellis:status               — Check project health
• /trellis:codemap              — Map your codebase
═══════════════════════════════════════════════════════════
```

## Notes

- This command is read-only by default; the only modification it may make is running `bd init` if the user approves
- If the user provides flags in `$ARGUMENTS`, respect them (e.g., `--skip-beads` to skip beads setup)
- This is a one-time setup command; subsequent runs will re-detect and report current state
