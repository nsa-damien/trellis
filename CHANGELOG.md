# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `/trellis.implement` enhanced with continuous execution and maximized parallelism
  - **Continuous execution**: Processes all beads without per-task prompts; only stops for genuine blockers
  - **Fresh agents per bead**: Each task gets isolated context via new Task invocation (no resume)
  - **Intelligent agent routing**: Routes tasks to specialized agents based on file patterns and keywords
    - `.tsx/.jsx/.vue/.svelte` → frontend-developer
    - API/endpoint/service → backend-architect
    - migration/schema/model → database-architect
    - `.py` → python-pro, `.go` → golang-pro, `.ts` → typescript-pro
  - **Maximized parallel execution**: Single-message multi-Task pattern for concurrent agent launches
  - **Graceful blocker handling**: Actionable messages with blocker categories (BC-001 through BC-005)
  - **Enhanced completion report**: Shows agent utilization, parallel batches, continuous execution stats

## [0.6.0] - 2026-01-15

### Added

- `/trellis.pr` command - Create pull requests for the current branch
  - Verifies branch state (must be on feature branch, no existing PR)
  - Handles uncommitted changes with user confirmation
  - Syncs beads if configured and uses related issues in PR description
  - Creates PR with structured description (Summary, Changes, Test Plan, Related Issues)
  - Supports draft PRs via "draft" argument
  - Handles closed/merged PR states with appropriate guidance
  - Bridges the gap between `/trellis.push` and `/trellis.release` in the workflow
- Workflow documentation in CLAUDE.md showing `/trellis.push` → `/trellis.pr` → `/trellis.release` sequence

### Changed

- `/trellis.release` now auto-creates a PR if one doesn't exist
  - No longer stops with "create a PR first" error
  - Checks for uncommitted changes and offers to commit them
  - Creates PR automatically, then continues with release process
  - Uses consistent PR template with Test Plan and Related Issues sections
- Improved error handling across PR commands
  - Explicit STOP conditions for `gh pr create` failures in both `/trellis.pr` and `/trellis.release`
  - Explicit STOP condition for push failures in `/trellis.release` auto-create flow
  - Better distinction between "no PR exists" vs network/auth errors
  - Detached HEAD state detection with clear user guidance
- Aligned force push warnings with `/trellis.push` (includes `--force-with-lease` warning)

## [0.5.1] - 2026-01-15

### Added

- USAGE.md with comprehensive step-by-step workflow guide
  - Covers full workflow: PRD creation → Epic decomposition → Specification → Implementation
  - Includes detailed command references and practical examples
  - Provides troubleshooting tips and best practices

## [0.5.0] - 2026-01-14

### Added

- `.claude-plugin/plugin.json` manifest for native Claude Code plugin installation
- `CLAUDE.md` for Claude Code guidance when working in this repository

### Changed

- **BREAKING:** License changed from MIT to Proprietary
  - Use restricted to North Shore Automation employees and contractors only
- Installation now uses `claude plugin install github:NorthShoreAutomation/trellis`
- Contributors can load locally via `claude --plugin-dir /path/to/trellis`

### Removed

- **BREAKING:** `install.sh` symlink-based installer removed
  - Existing users must migrate to plugin installation (see Migration section in README)

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

[Unreleased]: https://github.com/NorthShoreAutomation/trellis/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/NorthShoreAutomation/trellis/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/NorthShoreAutomation/trellis/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/NorthShoreAutomation/trellis/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/NorthShoreAutomation/trellis/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/NorthShoreAutomation/trellis/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/nsa-damien/trellis/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/nsa-damien/trellis/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/nsa-damien/trellis/releases/tag/v0.2.0
[0.1.1]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.1
[0.1.0]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.0
