# Code Mapping Feature Design

**Date:** 2026-01-20
**Status:** Approved
**Branch:** feature/code-mapping

## Overview

`/trellis.codemap` generates and maintains a `CODEMAP.yaml` file that maps domain concepts to code locations, enabling LLMs to quickly navigate to relevant code.

## Design Decisions

| Aspect | Decision |
|--------|----------|
| Primary use | Navigation ("where is X?"), secondary: modification impact |
| Output | `CODEMAP.yaml` at project root |
| Granularity | File + symbol (e.g., `internal/auth/handler.go:LoginHandler`) |
| Organization | By domain/capability |
| Mode | Autonomous + ask one question at a time for ambiguity |
| Generation | Hybrid: auto-skeleton + guided semantic enrichment |
| Scope | Generic (any codebase) |
| Updates | Subsequent runs detect drift, sequential validation |
| Languages (v1) | Go, TypeScript/JavaScript, Python |

## YAML Schema

```yaml
version: "1.0"
generated: "2026-01-20T10:30:00Z"
project:
  name: "project-name"
  type: "go"                    # detected primary language
  root: "."

modules:
  authentication:
    description: "User login, session management, JWT validation"
    entry_points:
      - internal/auth/handler.go:LoginHandler
      - internal/auth/middleware.go:RequireAuth
    key_types:                  # optional
      - internal/auth/session.go:Session
    interfaces:                 # optional
      - internal/auth/provider.go:AuthProvider
    tests: internal/auth/*_test.go  # optional
    depends_on: [config, database]  # optional
    spec: specs/003-authentication/ # optional
```

### Fields

**Required:**
- `description` - One-line semantic summary
- `entry_points` - Array of `file:Symbol` references

**Optional (include only when meaningful):**
- `key_types` - Core data structures
- `interfaces` - Extension points
- `tests` - Test location (glob pattern)
- `depends_on` - Other modules this uses
- `spec` - Link to spec-kit feature directory

## Command Flow

```
/trellis.codemap [--update]

PHASE 1: DETECTION
├── Detect project type (Go/TS/Python) from file extensions, config files
├── Scan directory structure, skip: node_modules, vendor, .git, dist, build
├── Identify candidate modules from top-level packages/directories
└── For each candidate, extract symbols using language-specific parser

PHASE 2: ANALYSIS
├── Score each symbol as potential entry point:
│   ├── High: exported, handler, main, router, public API
│   ├── Medium: exported type, interface, factory function
│   └── Low: internal helper, private function
├── Group symbols by module (directory/package boundaries)
├── Detect cross-module dependencies from imports
└── Flag ambiguities for clarification

PHASE 3: ENRICHMENT (Interactive)
├── For each detected module:
│   ├── Present auto-generated description
│   ├── Ask: "Is this description accurate?" [yes/edit]
│   └── Ask: "Link to a spec?" [list specs or skip]
├── For ambiguous modules:
│   └── Ask: "What is the purpose of internal/utils/?" [open response]
└── Skip questions for clear-cut modules

PHASE 4: OUTPUT
├── Generate CODEMAP.yaml
├── Display summary: "Created CODEMAP.yaml with N modules, M entry points"
└── Suggest: "Review and commit when ready"
```

### Update Mode

When `CODEMAP.yaml` exists or `--update` specified:
- Load existing file
- Run Phase 1-2 against current code
- Compute diff (new modules, removed modules, changed entry points)
- Sequential validation of each change:
  ```
  → "Module 'auth' has new entry point: internal/auth/oauth.go:OAuthHandler. Add it?" [yes/no/edit]
  → "Entry point internal/jobs/legacy.go:OldWorker removed. Remove from map?" [yes/no/keep]
  ```

## Language Detection

### Go
- **Trigger:** `go.mod` or `*.go` files at root
- **Entry points:** `func main()`, exported handlers, `ServeHTTP` implementations
- **Key types:** Exported structs, interfaces
- **Module boundaries:** Package directories

### TypeScript/JavaScript
- **Trigger:** `package.json`, `tsconfig.json`
- **Entry points:** `export default`, re-exports, route handlers, React components
- **Key types:** `export interface`, `export type`, `export class`
- **Module boundaries:** Directory structure, barrel files (index.ts)

### Python
- **Trigger:** `pyproject.toml`, `setup.py`, `requirements.txt`
- **Entry points:** `if __name__ == "__main__"`, decorated routes (`@app.route`), view functions
- **Key types:** `@dataclass`, Pydantic models, Django models
- **Module boundaries:** Package directories with `__init__.py`

### Fallback (Unknown)
- Directory structure analysis only
- Prompt for every module's purpose
- No symbol-level extraction

## Ambiguity Threshold

**Ask for clarification:**
- Multiple plausible domain groupings
- Unclear module purpose (generic names like `utils/`, `helpers/`)
- Conflicting signals (mixed test/source, unclear boundaries)

**Best-guess without asking:**
- Clear entry points exist (handlers, main, exports)
- Standard patterns detected (MVC, clean architecture)
- Single obvious interpretation

## Integration with /trellis.implement

After all beads complete in an implementation session:

1. Scan files modified during session
2. Extract new/changed symbols from those files
3. Compare against existing `CODEMAP.yaml`
4. If changes detected, sequential validation:
   ```
   → "New entry point auth/oauth.go:RefreshToken - add to 'authentication'?" [yes/no/different module]
   → "Entry point jobs/legacy.go:OldProcess no longer exists - remove?" [yes/no]
   ```
5. Write updated `CODEMAP.yaml`

**No CODEMAP exists:** Suggest running `/trellis.codemap` but don't create automatically.

**User defers:** Changes not written; next `/trellis.codemap` run detects them.
