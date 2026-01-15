# Feature Specification: Claude Plugin Structure

## Overview

**Feature Name:** Claude Plugin Structure
**Version:** 1.0
**Status:** Draft
**Created:** 2026-01-14

### Problem Statement

Trellis currently requires manual installation via a bash script that creates symlinks to command files. This approach has several drawbacks:

- Symlinks can break when the source repository moves or is deleted
- Installation requires running a script with specific flags
- No integration with Claude's native plugin discovery and management
- Users cannot easily update or uninstall the plugin
- The installation process differs from the standard Claude plugin workflow

### Proposed Solution

Configure Trellis as a native Claude Code plugin that users can install directly from GitHub using the standard `claude plugin add` command. This eliminates symlinks entirely and follows Claude's built-in plugin management system.

### Success Criteria

1. Users can install Trellis with a single command: `claude plugin install github:NorthShoreAutomation/trellis`
2. All existing Trellis commands (`/trellis.import`, `/trellis.sync`, etc.) work after installation
3. Users can update the plugin using Claude's standard update mechanism
4. Users can uninstall cleanly without orphaned files or broken references
5. The installation process matches the pattern used by official Claude plugins

---

## Functional Requirements

### FR-1: Plugin Manifest

The repository must include a plugin manifest file that describes Trellis to Claude's plugin system.

**Acceptance Criteria:**
- Plugin manifest exists at the expected location in the repository
- Manifest includes plugin name, version, and description
- Manifest includes author and license information
- Plugin name follows kebab-case naming convention

### FR-2: Command Discovery

All Trellis commands must be discoverable by Claude's plugin system without additional configuration.

**Acceptance Criteria:**
- Commands remain in the `commands/` directory (current location)
- All 10 existing commands are available after plugin installation:
  - `/trellis.import`
  - `/trellis.sync`
  - `/trellis.ready`
  - `/trellis.status`
  - `/trellis.prd`
  - `/trellis.epics`
  - `/trellis.implement`
  - `/trellis.test-plan`
  - `/trellis.push`
  - `/trellis.release`
- Command behavior is identical to the current symlink-based installation

### FR-3: Installation Experience

Users must be able to install Trellis using Claude's native plugin installation workflow.

**Acceptance Criteria:**
- Installation works via `claude plugin install github:NorthShoreAutomation/trellis`
- No manual steps required after the install command
- Installation provides feedback confirming available commands
- Failed installations provide clear error messages

### FR-4: Documentation Updates

Installation documentation must reflect the new plugin-based approach.

**Acceptance Criteria:**
- README includes updated installation instructions for end users (GitHub-based)
- README includes development installation instructions for contributors (local path-based)
- Prerequisites section reflects actual requirements (Claude Code only, beads/spec-kit as needed)
- Legacy symlink installation documentation is removed

### FR-5: Backward Compatibility

Existing users with symlink installations should have a clear migration path.

**Acceptance Criteria:**
- Documentation explains how to migrate from symlinks to plugin installation
- The legacy install script is removed

### FR-6: Development Workflow

Contributors must be able to install Trellis from a local path for development and testing.

**Acceptance Criteria:**
- Local path installation works via `claude --plugin-dir /path/to/trellis`
- Edits to command files are reflected immediately without reinstallation
- Development workflow is documented in README

---

## User Scenarios & Testing

### Scenario 1: New User Installation

**Actor:** Developer who has never used Trellis
**Goal:** Install Trellis to use with their project

**Flow:**
1. User has Claude Code installed
2. User runs `claude plugin install github:NorthShoreAutomation/trellis`
3. Claude confirms successful installation and lists available commands
4. User runs `/trellis.status` to verify commands work

**Expected Outcome:** All Trellis commands are available and functional

### Scenario 2: Existing User Migration

**Actor:** Developer with existing symlink-based Trellis installation
**Goal:** Migrate to the plugin-based installation

**Prerequisite:** User must remove existing symlinks before installing the plugin to avoid duplicate command definitions.

**Flow:**
1. User reads migration documentation
2. User removes existing symlinks from `~/.claude/commands/` or `.claude/commands/` (required prerequisite)
3. User installs via plugin: `claude plugin install github:NorthShoreAutomation/trellis`
4. User verifies commands work as expected

**Expected Outcome:** Clean transition with no duplicate or conflicting command definitions

### Scenario 3: Plugin Update

**Actor:** Existing Trellis plugin user
**Goal:** Update to latest version when new features are released

**Flow:**
1. User learns of new Trellis version
2. User runs `claude plugin update trellis` (or equivalent Claude command)
3. New commands/features become available

**Expected Outcome:** Seamless update without manual intervention

### Scenario 4: Contributor Development

**Actor:** Developer contributing to Trellis
**Goal:** Test command changes locally before committing

**Flow:**
1. Contributor clones the Trellis repository
2. Contributor installs from local path: `claude --plugin-dir /path/to/trellis`
3. Contributor edits command files in `commands/`
4. Changes are immediately available when invoking `/trellis.*` commands
5. Contributor tests, iterates, and commits when ready

**Expected Outcome:** Fast development cycle with immediate feedback on command changes

---

## Assumptions

1. Claude Code's plugin system supports installation from public GitHub repositories
2. Claude Code's plugin system supports installation from local file paths for development
3. The `commands/` directory location is auto-discovered by Claude's plugin loader
4. Plugin updates are handled by Claude's plugin management system
5. The repository name and owner (NorthShoreAutomation/trellis) remain stable

---

## Out of Scope

- Converting Trellis into a marketplace hosting multiple plugins
- Adding MCP server functionality
- Adding hooks or agents (can be added in future iterations)
- Automated testing of plugin installation (manual verification is sufficient)
- Publishing to a central plugin registry (GitHub-based installation is sufficient)

---

## Dependencies

- Claude Code with plugin support (released October 2025)
- Public GitHub repository access

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Plugin manifest schema changes | Commands may fail to load | Pin to stable schema version, monitor Claude release notes |
| GitHub rate limiting affects installation | Users cannot install | Document alternative installation methods if needed |
| Users have outdated Claude Code without plugin support | Installation fails | Document minimum Claude Code version requirement |

---

## Key Entities

### Plugin Manifest
- Name (string): Unique identifier for the plugin
- Version (string): Semantic version number
- Description (string): Human-readable description
- Author (object): Name and contact information
- License (string): Open source license identifier

### Command
- File (markdown): Command definition file
- Name (string): Slash command name (e.g., "trellis.import")
- Description (string): What the command does

---

## Clarifications

### Session 2026-01-14

- Q: Should the legacy install.sh be removed or kept with deprecation notice? → A: Remove entirely, rely solely on plugin installation
- Q: How to handle duplicate commands if user doesn't remove symlinks before plugin install? → A: Document prerequisite only; user must remove symlinks first
- Q: How do contributors test commands during development? → A: Local path installation via `claude --plugin-dir /path/to/trellis`; README must document this workflow
