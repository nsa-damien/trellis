# Research: Claude Plugin Structure

## Plugin Manifest Schema

### Decision
Use the standard `.claude-plugin/plugin.json` manifest format with recommended metadata fields.

### Rationale
This is the official format used by Anthropic's own plugins (e.g., `commit-commands`, `pr-review-toolkit`). It ensures compatibility with Claude Code's plugin discovery and installation system.

### Findings

**Required fields:**
- `name` (string): Kebab-case plugin identifier

**Recommended fields:**
- `version` (string): Semantic version (e.g., "1.0.0")
- `description` (string): Brief explanation of plugin purpose
- `author` (object): Contains `name` and `email`

**Optional fields:**
- `homepage` (string): Documentation URL
- `repository` (string): GitHub repository URL
- `license` (string): License identifier (e.g., "MIT")
- `keywords` (array): Discovery tags

**Example from official plugin:**
```json
{
  "name": "commit-commands",
  "description": "Streamline your git workflow with simple commands",
  "version": "1.0.0",
  "author": {
    "name": "Anthropic",
    "email": "support@anthropic.com"
  }
}
```

### Alternatives Considered
- Marketplace configuration (`marketplace.json`): Not needed for single plugin
- Custom manifest location: Would break auto-discovery

---

## Directory Structure

### Decision
Use `skills/` and `agents/` at repository root. Keep `.claude-plugin/plugin.json` for Claude Code discovery.

### Rationale
Claude Code auto-discovers components from standard directory locations at plugin root level. `skills/` and `agents/` are standard plugin component locations.

### Findings

**Standard structure:**
```
trellis/
├── .claude-plugin/
│   └── plugin.json          # NEW - Required manifest
├── skills/
│   ├── trellis.import/
│   │   └── SKILL.md
│   └── ...
├── agents/
│   └── ...
├── README.md                # UPDATE - New install instructions
└── ...
```

**Auto-discovery behavior:**
1. Claude reads `.claude-plugin/plugin.json` when plugin enables
2. Scans `skills/` and `agents/` automatically
3. No registration needed in manifest

### Alternatives Considered
- Moving commands inside `.claude-plugin/`: Would break auto-discovery
- Adding `commands` path to manifest: Unnecessary, default location works

---

## Installation Methods

### Decision
Support both GitHub installation (end users) and local path installation (contributors).

### Rationale
GitHub installation provides easy distribution. Local path installation enables development workflow without reinstalling after each change.

### Findings

**End user installation:**
```bash
claude plugin install github:NorthShoreAutomation/trellis
```

**Contributor installation:**
```bash
claude --plugin-dir /path/to/trellis
```

**Key behaviors:**
- Local path installation references the directory (not copies)
- Edits to command files are reflected immediately
- No reinstallation needed during development

### Alternatives Considered
- npm package: Adds complexity, not needed for this use case
- Symlink approach: Replaced by native local path support

---

## Files to Remove

### Decision
Remove `install.sh` entirely.

### Rationale
The native plugin system replaces all functionality provided by the symlink-based installer. Keeping it would cause confusion and maintenance burden.

### Findings
Current `install.sh` functionality:
- Creates symlinks to `~/.claude/commands/` or `.claude/commands/`
- Supports `--user` and `--project` flags
- Provides `--uninstall` option

All of this is replaced by:
- `claude plugin add` (install)
- `claude plugin remove` (uninstall)
- Native plugin management (updates)

### Alternatives Considered
- Keep with deprecation warning: Adds confusion, user might use wrong method
- Convert to development helper: Not needed, local path install is simpler

---

## Sources

- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Plugin Structure Reference](https://claude-plugins.dev/skills/@anthropics/claude-plugins-official/plugin-structure)
- [Official Claude Plugins Repository](https://github.com/anthropics/claude-code/tree/main/plugins)
- [commit-commands plugin.json](https://github.com/anthropics/claude-code/blob/main/plugins/commit-commands/.claude-plugin/plugin.json)
