# Trellis Usage Guide

Step-by-step workflow for spec-driven development with Trellis.

## Prerequisites

### Install Trellis

```bash
claude plugin install github:NorthShoreAutomation/trellis
```

### Install and Initialize Beads

```bash
# Install beads CLI
cargo install beads

# Initialize in your project
cd your-project
bd init
```

### Install Spec-Kit

Spec-kit commands are bundled with Trellis. No separate installation needed.

---

## Workflow Overview

```
PRD → Epics → Specify → Clarify → Plan → Tasks → Analyze → Import → Implement → Test Plan → Push → Release
```

---

## Step 1: Generate Product Requirements

```bash
/trellis.prd
```

Interactive PRD development workflow through structured discovery. Claude guides you through:
- Problem definition and goals
- User personas and scenarios
- Functional requirements
- Success criteria

**Output:** User-specified path (e.g., `./docs/prd-feature-name.md`)

---

## Step 2: Break Down into Epics

```bash
/trellis.epics
```

Breaks the PRD into sequenced, LLM-executable epics. Each epic is a self-contained phase of work that moves the project forward by a measurable step.

**Output:** `docs/epics/` directory containing:
- `index.md` - Epic overview and sequencing
- `001-epic-name.md`, `002-epic-name.md`, etc. - Individual epic files

---

## Step 3: Create Feature Specification

```bash
/speckit.specify docs/epics/001-epic-name.md
```

Creates a feature specification from an epic or natural language description. Creates a feature branch and spec directory.

**Input:** Epic file path or feature description
**Output:** `specs/{feature-id}/spec.md` (also creates feature branch)

---

## Step 4: Clarify Requirements

```bash
/speckit.clarify
```

Identifies underspecified areas in the current spec. Asks up to 5 highly targeted clarification questions, then encodes answers back into the specification.

**Output:** Updated `specs/{feature}/spec.md` with clarifications section

---

## Step 5: Create Implementation Plan

```bash
/speckit.plan
```

Executes the implementation planning workflow using the plan template. Generates design artifacts based on spec complexity.

**Output:** In `specs/{feature}/`:
- `research.md` - Technology decisions and research findings
- `plan.md` - Implementation approach
- `data-model.md` - Data structures (if applicable)
- `contracts/` - API contracts (if applicable)
- `quickstart.md` - Getting started guide (if applicable)

---

## Step 6: Generate Tasks

```bash
/speckit.tasks
```

Generates actionable, dependency-ordered tasks from the spec and plan artifacts.

**Output:** `specs/{feature}/tasks.md`

---

## Step 7: Analyze for Consistency

```bash
/speckit.analyze
```

Non-destructive cross-artifact consistency and quality analysis. Reviews spec.md, plan.md, and tasks.md for gaps, inconsistencies, and issues.

**Output:** Analysis report (displayed, no files modified)

---

## Step 8: Import to Beads

```bash
/trellis.import
```

Imports tasks.md into beads issue tracker with:
- Dependency graph for execution ordering
- Phase-based epic hierarchy
- Parallel task detection

**Output:**
- Beads issues with dependencies
- `specs/{feature}/beads-mapping.json` - Maps task IDs to bead IDs

---

## Step 9: Implement with Tracking

```bash
/trellis.implement
```

Executes tasks using beads for dependency-aware ordering:
- Automatically picks next available task from `bd ready`
- Routes to specialized agents based on task type
- Updates beads status as work completes
- Syncs progress back to tasks.md

**Requires:** `specs/{feature}/beads-mapping.json` (created by `/trellis.import`)

---

## Step 10: Generate Test Plan

```bash
/trellis.test-plan
```

Generates manual test documentation for a feature specification.

**Output:** In `specs/{feature}/`:
- `test-plan.md` - Test plan documentation
- `tests/manual.md` (or `.feature`, `.yaml`) - Manual test file

---

## Step 11: Commit and Push

```bash
/trellis.push
```

Commits and pushes current changes with:
- Beads sync for issue state
- CHANGELOG.md updates
- Conventional commit messages

---

## Step 12: Create Pull Request

Create a PR using standard git workflow:

```bash
gh pr create --title "feat: your feature" --body "Description"
```

---

## Step 13: Create Release

```bash
/trellis.release
```

Creates a release from an existing PR:
- Determines semantic version from changes
- Updates CHANGELOG.md
- Creates release notes in `docs/release/`
- Merges PR
- Tags and publishes GitHub release

---

## Quick Reference

| Phase | Command | Purpose |
|-------|---------|---------|
| Requirements | `/trellis.prd` | Interactive PRD development |
| Planning | `/trellis.epics` | Break PRD into epics |
| Specification | `/speckit.specify` | Create feature spec from epic |
| Clarification | `/speckit.clarify` | Resolve ambiguities |
| Design | `/speckit.plan` | Generate design artifacts |
| Tasks | `/speckit.tasks` | Generate task breakdown |
| Validation | `/speckit.analyze` | Consistency check (read-only) |
| Tracking | `/trellis.import` | Import tasks to beads |
| Execution | `/trellis.implement` | Build with beads tracking |
| Testing | `/trellis.test-plan` | Generate test documentation |
| Commit | `/trellis.push` | Push with changelog |
| Release | `/trellis.release` | Publish release from PR |

---

## Utility Commands

| Command | Purpose |
|---------|---------|
| `/trellis.status` | Project health overview |
| `/trellis.ready` | Show unblocked tasks |
| `/trellis.sync` | Sync beads ↔ tasks.md |
| `bd ready` | Beads: available work |
| `bd stats` | Beads: project statistics |
| `bd show <id>` | Beads: issue details |

---

## Tips

- Run `/speckit.analyze` before `/trellis.import` to catch issues early
- Use `/trellis.status` anytime to check progress
- The workflow is iterative - you can re-run clarify/plan/tasks as needed
- Each epic can go through steps 3-11 independently
- The beads-mapping.json file links tasks.md entries to beads issues
