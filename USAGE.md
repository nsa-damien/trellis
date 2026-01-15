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
PRD → Epics → Specify → Clarify → Plan → Tasks → Analyze → Import → Implement → Push → Release
```

---

## Step 1: Generate Product Requirements

```bash
/trellis.prd
```

Creates a Product Requirements Document through interactive discovery. Captures:
- Problem statement and goals
- User personas and scenarios
- Functional requirements
- Success criteria

**Output:** `specs/{feature}/prd.md`

---

## Step 2: Break Down into Epics

```bash
/trellis.epics
```

Breaks the PRD into sequenced, manageable epics. Each epic represents a discrete phase of work that can be implemented independently.

**Output:** `specs/{feature}/epics/` directory with individual epic files

---

## Step 3: Create Feature Specification

```bash
/speckit.specify specs/{feature}/epics/001-epic-name.md
```

Generates a detailed feature specification from an epic. Pass the epic file path as the input source.

**Output:** `specs/{feature}/spec.md`

---

## Step 4: Clarify Requirements

```bash
/speckit.clarify
```

Identifies underspecified areas in the spec and asks targeted clarification questions. Encodes answers back into the specification.

**Output:** Updated `specs/{feature}/spec.md` with clarifications

---

## Step 5: Create Implementation Plan

```bash
/speckit.plan
```

Generates the technical implementation plan including:
- Architecture decisions
- Technology choices
- Implementation phases
- Risk mitigations

**Output:** `specs/{feature}/plan.md`

---

## Step 6: Generate Tasks

```bash
/speckit.tasks
```

Creates an actionable, dependency-ordered task breakdown from the spec and plan.

**Output:** `specs/{feature}/tasks.md`

---

## Step 7: Analyze for Consistency

```bash
/speckit.analyze
```

Performs cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md. Identifies gaps and inconsistencies before implementation.

**Output:** Analysis report with recommendations

---

## Step 8: Import to Beads

```bash
/trellis.import
```

Imports tasks.md into beads issue tracker with:
- Dependency graph for execution ordering
- Phase-based epic hierarchy
- Parallel task detection

**Output:** Beads issues with dependencies

---

## Step 9: Implement with Tracking

```bash
/trellis.implement
```

Executes tasks using beads for dependency-aware ordering:
- Automatically picks next available task
- Routes to specialized agents based on task type
- Updates beads status as work completes
- Syncs progress back to tasks.md

---

## Step 10: Commit and Push

```bash
/trellis.push
```

Commits and pushes changes with:
- Beads sync for issue state
- CHANGELOG.md updates
- Conventional commit messages

---

## Step 11: Create Pull Request

```bash
# Future: /trellis.open-pr
```

*Coming soon* - Automated PR creation with summary from completed work.

---

## Step 12: Review Pull Request

```bash
# Future: /trellis.pr-review
```

*Coming soon* - Comprehensive PR review using specialized agents.

---

## Step 13: Create Release

```bash
/trellis.release
```

Creates a release from an existing PR:
- Determines semantic version from changes
- Updates CHANGELOG.md
- Creates release notes
- Merges PR
- Tags and publishes GitHub release

---

## Quick Reference

| Phase | Command | Purpose |
|-------|---------|---------|
| Requirements | `/trellis.prd` | Generate PRD |
| Planning | `/trellis.epics` | Break into epics |
| Specification | `/speckit.specify` | Create feature spec |
| Clarification | `/speckit.clarify` | Resolve ambiguities |
| Design | `/speckit.plan` | Technical planning |
| Tasks | `/speckit.tasks` | Task breakdown |
| Validation | `/speckit.analyze` | Consistency check |
| Tracking | `/trellis.import` | Import to beads |
| Execution | `/trellis.implement` | Build with tracking |
| Commit | `/trellis.push` | Push changes |
| Release | `/trellis.release` | Publish release |

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
- Each epic can go through steps 3-10 independently
