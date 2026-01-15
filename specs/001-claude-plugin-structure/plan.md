# Implementation Plan: Claude Plugin Structure

## Overview

| Field | Value |
|-------|-------|
| Feature | Claude Plugin Structure |
| Branch | `001-claude-plugin-structure` |
| Spec | `specs/001-claude-plugin-structure/spec.md` |
| Research | `specs/001-claude-plugin-structure/research.md` |

## Technical Context

| Aspect | Details |
|--------|---------|
| Languages | JSON (manifest), Markdown (documentation) |
| Frameworks | Claude Code plugin system |
| External Dependencies | None |
| Affected Components | Repository root structure, README |

## Implementation Phases

### Phase 1: Plugin Manifest

**Goal:** Create the plugin manifest file for Claude Code discovery.

**Tasks:**

1. Create directory `.claude-plugin/`
2. Create `.claude-plugin/plugin.json` with contents:
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
     "license": "Proprietary",
     "keywords": ["spec-kit", "beads", "task-tracking", "planning"]
   }
   ```

**Verification:**
- [ ] File exists at `.claude-plugin/plugin.json`
- [ ] JSON is valid (no syntax errors)
- [ ] Version matches current release in CHANGELOG

**Files:**
- CREATE: `.claude-plugin/plugin.json`

---

### Phase 2: Remove Legacy Installer

**Goal:** Remove the symlink-based installation script.

**Tasks:**

1. Delete `install.sh`

**Verification:**
- [ ] `install.sh` no longer exists
- [ ] No broken references to `install.sh` in documentation

**Files:**
- DELETE: `install.sh`

---

### Phase 3: Update Documentation

**Goal:** Update README with new installation instructions and migration guide.

**Tasks:**

1. Replace Installation section with plugin-based instructions
2. Add Development section for contributors
3. Add Migration section for existing users
4. Remove references to `install.sh`
5. Update Prerequisites to reflect plugin requirements

**New README structure:**

```markdown
## Installation

### For Users

```bash
claude plugin install github:NorthShoreAutomation/trellis
```

### For Contributors

```bash
git clone https://github.com/NorthShoreAutomation/trellis.git
claude --plugin-dir /path/to/trellis
```

## Migrating from Symlink Installation

If you previously installed Trellis using `install.sh`:

1. Remove existing symlinks:
   ```bash
   rm ~/.claude/commands/trellis.*.md
   # or for project-level:
   rm .claude/commands/trellis.*.md
   ```

2. Install via plugin:
   ```bash
   claude plugin install github:NorthShoreAutomation/trellis
   ```
```

**Verification:**
- [ ] README contains plugin installation instructions
- [ ] README contains development workflow
- [ ] README contains migration guide
- [ ] No references to `install.sh` remain

**Files:**
- UPDATE: `README.md`

---

### Phase 4: Verification

**Goal:** Verify the plugin works correctly.

**Tasks:**

1. Install plugin from local path: `claude plugin add /path/to/trellis`
2. Verify all 10 commands are available
3. Test one command (e.g., `/trellis.status`)
4. Uninstall and reinstall to verify clean cycle

**Verification:**
- [ ] `claude plugin add` succeeds
- [ ] All `/trellis.*` commands appear in command list
- [ ] Commands execute correctly
- [ ] `claude plugin remove` works cleanly

---

## Files Summary

| Action | File |
|--------|------|
| CREATE | `.claude-plugin/plugin.json` |
| DELETE | `install.sh` |
| UPDATE | `README.md` |

## Definition of Done

- [ ] Plugin manifest exists and is valid JSON
- [ ] Legacy install script removed
- [ ] README updated with new installation instructions
- [ ] README includes contributor development workflow
- [ ] README includes migration guide for existing users
- [ ] Plugin installs successfully via `claude plugin add`
- [ ] All 10 commands discoverable and functional
- [ ] CHANGELOG updated with breaking change note

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Users miss migration instructions | Add prominent note in CHANGELOG and README |
| Plugin manifest schema incorrect | Validated against official examples |
| Commands not discovered | Using standard `commands/` location |

## Notes

- This is a configuration change, not a code change
- No API contracts or data models needed
- Version in plugin.json should match CHANGELOG version
