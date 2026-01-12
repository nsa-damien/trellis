# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `/trellis.epics` command - Break down a PRD into sequenced, LLM-executable epics for phased implementation
- `/trellis.implement` now generates comprehensive `test-plan.md` after implementation completion
  - Test environment setup (prerequisites, setup steps, test accounts)
  - Manual verification checklist organized by phase and user story
  - Feature testing scenarios with step-by-step instructions
  - Customized for tech stack (API curl examples, DevTools checks, CLI examples as applicable)

## [0.1.2] - 2025-12-28

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

[Unreleased]: https://github.com/nsa-damien/trellis/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.2
[0.1.1]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.1
[0.1.0]: https://github.com/nsa-damien/trellis/releases/tag/v0.1.0
