# Tasks: Claude Plugin Structure

## Overview

**Feature:** Configure Trellis as a native Claude Code plugin
**Branch:** `001-claude-plugin-structure`
**Type:** Configuration/Documentation (no code changes)

---

## Phase 1: Setup

**Purpose:** Create the plugin manifest directory and file.

**Checkpoint:** Plugin manifest exists and is valid JSON.

### Tasks

- [ ] T001 Create plugin directory at `.claude-plugin/`
- [ ] T002 Create plugin manifest at `.claude-plugin/plugin.json` with the following content:
  ```json
  {
    "name": "trellis",
    "description": "Bridge spec-kit planning with beads issue tracking for Claude Code",
    "version": "0.5.0",
    "author": {
      "name": "NorthShoreAutomation",
      "email": "support@northshoreautomation.com"
    },
    "repository": "https://github.com/NorthShoreAutomation/trellis",
    "license": "MIT",
    "keywords": ["spec-kit", "beads", "task-tracking", "planning"]
  }
  ```
- [ ] T003 Validate JSON syntax in `.claude-plugin/plugin.json`

---

## Phase 2: Cleanup

**Purpose:** Remove legacy installation infrastructure.

**Checkpoint:** Legacy install script is deleted.

### Tasks

- [ ] T004 Delete legacy installation script `install.sh`

---

## Phase 3: Documentation

**Purpose:** Update README with new installation instructions, development workflow, and migration guide.

**Checkpoint:** README contains complete plugin installation documentation.

### Tasks

- [ ] T005 Update Installation section in `README.md` with plugin-based instructions:
  - End user installation: `claude plugin add github:NorthShoreAutomation/trellis`
  - Contributor installation: `claude plugin add /path/to/local/trellis`
- [ ] T006 [P] Add Development section to `README.md` explaining local path installation for contributors
- [ ] T007 [P] Add Migration section to `README.md` explaining how to migrate from symlink installation:
  - Remove existing symlinks from `~/.claude/commands/` or `.claude/commands/`
  - Install via plugin command
- [ ] T008 Update Prerequisites section in `README.md` to reflect plugin requirements (Claude Code only)
- [ ] T009 Remove all references to `install.sh` from `README.md`

---

## Phase 4: Changelog

**Purpose:** Document the breaking change in CHANGELOG.

**Checkpoint:** CHANGELOG reflects the plugin structure change.

### Tasks

- [ ] T010 Add entry to `CHANGELOG.md` under [Unreleased] section:
  - Added: `.claude-plugin/plugin.json` manifest for native plugin installation
  - Changed: Installation now uses `claude plugin add` instead of `install.sh`
  - Removed: `install.sh` symlink-based installer (breaking change)
  - Note migration instructions for existing users

---

## Phase 5: Verification

**Purpose:** Verify the plugin works correctly.

**Checkpoint:** Plugin installs and all commands are discoverable.

### Tasks

- [ ] T011 Install plugin from local path: `claude plugin add /path/to/trellis`
- [ ] T012 Verify all 10 commands are available in Claude Code:
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
- [ ] T013 Test one command (e.g., `/trellis.status`) to verify functionality
- [ ] T014 Remove and reinstall plugin to verify clean uninstall/reinstall cycle

---

## Dependencies & Execution Order

```
Phase 1 (Setup) ──┐
                  ├──► Phase 3 (Documentation) ──► Phase 4 (Changelog) ──► Phase 5 (Verification)
Phase 2 (Cleanup)─┘
```

**Notes:**
- Phase 1 and Phase 2 can run in parallel
- Phase 3 depends on Phase 2 (can't document removal before removing)
- Phase 4 depends on Phase 3 (changelog summarizes all changes)
- Phase 5 must be last (verifies complete implementation)

---

## Parallel Execution Opportunities

**Phase 1-2 (parallel):**
- T001-T003 (setup) can run in parallel with T004 (cleanup)

**Phase 3 (parallel within phase):**
- T006 and T007 are marked [P] - can run in parallel after T005 completes

---

## Files Summary

| Action | File |
|--------|------|
| CREATE | `.claude-plugin/plugin.json` |
| DELETE | `install.sh` |
| UPDATE | `README.md` |
| UPDATE | `CHANGELOG.md` |

---

## Implementation Notes

- This is a configuration change, not a code change
- No data models or API contracts needed
- Version in plugin.json (0.5.0) will be the new release version
- The `commands/` directory remains unchanged - Claude auto-discovers it
