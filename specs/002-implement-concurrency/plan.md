# Implementation Plan: Implement Concurrency Enhancement

**Branch**: `002-implement-concurrency` | **Date**: 2026-01-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-implement-concurrency/spec.md`

## Summary

Enhance the `/trellis.implement` command to process all open beads continuously until completion (stopping only for genuine blockers), spawn fresh agents per bead via the Task tool, route tasks to specialized agents based on task characteristics, and maximize parallel execution using single-message multi-Task patterns.

## Technical Context

**Language/Version**: Markdown (Claude Code command file format)
**Primary Dependencies**: Claude Code Task tool, beads CLI (`bd`), speckit scripts
**Storage**: N/A (stateless command orchestration; beads handles persistence)
**Testing**: Manual testing via `/trellis.implement` invocation with various bead configurations
**Target Platform**: Claude Code CLI environment (macOS/Linux)
**Project Type**: Single command file modification
**Performance Goals**: Execute 10+ tasks without manual intervention; parallel batches complete faster than sequential
**Constraints**: Must work within Claude Code's tool invocation model; respect existing command flags
**Scale/Scope**: Single command file (~200 lines); affects all `/trellis.implement` invocations

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The constitution template is unpopulated for this project. Applying general best practices:

| Gate | Status | Notes |
|------|--------|-------|
| Single file change | ✅ PASS | Modifying only `skills/trellis.implement/SKILL.md` |
| No new dependencies | ✅ PASS | Uses existing Task tool, bd CLI, agent types |
| Backwards compatible | ✅ PASS | Existing flags preserved; new behavior is default |
| Testable | ✅ PASS | Can be tested with existing beads projects |

## Project Structure

### Documentation (this feature)

```text
specs/002-implement-concurrency/
├── plan.md              # This file
├── research.md          # Phase 0: Best practices for parallel Task invocation
├── data-model.md        # Phase 1: Bead/Agent/Batch entity relationships
├── quickstart.md        # Phase 1: How to test the enhanced command
└── tasks.md             # Phase 2: Implementation tasks (generated separately)
```

### Source Code (repository root)

```text
skills/
└── trellis.implement/
    └── SKILL.md    # THE ONLY FILE BEING MODIFIED
```

**Structure Decision**: This is a single-file enhancement to an existing command. No new directories or files in the source tree are required.

## Complexity Tracking

No constitution violations requiring justification.
