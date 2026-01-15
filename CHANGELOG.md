# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.1] - 2026-01-14

### Fixed

- `/trellis.push` and `/trellis.release` commands now use `description` frontmatter (project convention)
- Added beads availability check before running `bd` commands to prevent errors when beads is not configured
- Fixed prerelease detection instructions in `/trellis.release` for clarity
- Corrected step number references in error recovery documentation
- Simplified commit message instructions in `/trellis.push`

## [0.4.0] - 2026-01-14

### Added

- `/trellis.push` command - Commit and push changes with proper workflow integration
  - Runs `bd sync` for beads integration
  - Checks for in-progress issues that should be closed
  - Updates CHANGELOG.md for notable changes
  - Writes concise conventional commit messages
  - Supports beads workflow with `--from-main` sync for ephemeral branches
- `/trellis.release` command - Create releases with changelog, release notes, and tagged GitHub releases from existing PRs
  - Validates open PR exists before proceeding
  - Analyzes changes and determines semantic version (major/minor/patch)
  - Updates CHANGELOG.md following Keep a Changelog format
  - Creates release notes in `docs/release/v{version}.md`
  - Merges PR, creates annotated git tag, and publishes GitHub release
  - Supports pre-release versions (alpha/beta/rc) with automatic detection
  - Includes comprehensive error recovery and rollback instructions

## [0.3.1] - 2026-01-14

### Changed

- `/trellis.test-plan` command now works without beads integration
  - If `beads-mapping.json` is not found, proceeds with spec-based test generation instead of stopping
  - Allows the command to work in projects that don't use beads for task tracking

## [0.3.0] - 2026-01-14

### Added

- `/trellis.test-plan` command - Generate manual test file and test plan documentation for a feature specification
  - Creates runnable test file (`FEATURE_DIR/tests/manual.{ext}`) with HTTP logging transport
  - Generates `FEATURE_DIR/test-plan.md` with verification checklists and testing scenarios
  - Supports Go, Python, TypeScript, and JavaScript
  - Includes sensitive data masking for shareable logs

### Fixed

- `/trellis.implement` now always generates test-plan.md by executing test plan generation BEFORE final completion validation
  - Previously, step 13 "Completion validation" closed the root epic, causing agents to stop before reaching step 14 "Generate manual test plan"
  - Reordered steps so test plan generation (step 13) happens before completion validation and epic closure (step 14)
  - Ensures test-plan.md is consistently created for all successful implementations
- Refactored `/trellis.implement` command file from 667 lines to 159 lines (76% reduction)
  - Removed excessive pseudocode and verbose bd command examples
  - Consolidated redundant sections while preserving all functionality
  - Improved clarity by following speckit.implement's concise style
  - Maintained all features: parallel execution, agent specialization, validation, test plan generation

### Changed

- `/trellis.implement` now uses parallel agent orchestration for 3-5x faster implementation
  - Launches multiple specialized agents simultaneously when tasks are unblocked
  - Routes tasks to domain experts: frontend-developer, backend-architect, database-architect, python-pro, typescript-pro, golang-pro
  - Hybrid conflict detection: predicts file overlaps and serializes conflicting tasks
  - Medium validation: verifies files exist, syntax is valid, and relevant tests pass before marking complete
  - Configurable parallelism via `--parallel-limit N` (default: 3) and `--no-parallel` flags
  - All implementation agents use Opus model for complex work
  - Completion report now includes parallel execution statistics and agent utilization

## [0.2.0] - 2026-01-12

### Added

- `/trellis.epics` command - Break down a PRD into sequenced, LLM-executable epics for phased implementation
- `/trellis.prd` command - Interactive PRD development workflow through structured discovery
- `/trellis.implement` now generates comprehensive `test-plan.md` after implementation completion
  - Test environment setup (prerequisites, setup steps, test accounts)
  - Manual verification checklist organized by phase and user story
  - Feature testing scenarios with step-by-step instructions
  - Customized for tech stack (API curl examples, DevTools checks, CLI examples as applicable)

### Changed

- Streamlined README from 435 to 80 lines
- Simplified AGENTS.md to essential commands and checklist
- Updated ARCHITECTURE.md with correct command names

### Removed

- Redundant docs/AGENTS-snippet.md (content now in main docs)

## [0.1.2] - 2025-12-28 [YANKED]

### Changed

- Streamlined README from 435 to 80 lines
- Simplified AGENTS.md to essential commands and checklist
- Updated ARCHITECTURE.md with correct command names

### Removed

- Redundant docs/AGENTS-snippet.md (content now in main docs)

## [0.1.1] - 2025-12-28

### Changed

- Install script now creates symlinks instead of copying command files, ensuring updates to source files are immediately reflected

## [0.1.0] - 2025-12-28

### Added

- `/trellis.import` command - Import spec-kit tasks.md into beads issue tracker
- `/trellis.implement` command - Execute tasks with dependency-aware ordering via `bd ready`
- `/trellis.sync` command - Bidirectional sync between beads and tasks.md
- `/trellis.ready` command - Quick check of unblocked work
- `/trellis.status` command - Project health and statistics overview
- `install.sh` script for user-level or project-level installation
- Example `beads-mapping.json` showing integration schema
- Architecture documentation explaining the spec-kit/beads bridge
- AGENTS.md snippet for automatic beads awareness in Claude Code

[Unreleased]: https://github.com/NorthShoreAutomation/trellis/compare/v0.4.1...HEAD
[0.4.1]: https://github.com/NorthShoreAutomation/trellis/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/NorthShoreAutomation/trellis/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/nsa-damien/trellis/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/nsa-damien/trellis/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/nsa-damien/trellis/releases/tag/v0.2.0
[0.1.1]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.1
[0.1.0]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.0
