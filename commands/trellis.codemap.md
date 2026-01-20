---
description: Generate or update CODEMAP.yaml - a semantic map of code locations for LLM navigation
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Overview

This command generates a `CODEMAP.yaml` file that maps domain concepts to code locations, enabling LLMs to quickly find relevant code. It uses a hybrid approach: auto-detect structure, then ask targeted questions for semantic enrichment.

**Key principles:**
- Navigation-focused: "Where is the code for X?"
- File + symbol granularity: `internal/auth/handler.go:LoginHandler`
- Domain/capability organization (not layers)
- Compact: only include meaningful information
- Ask questions one at a time, only for substantial ambiguity

## Outline

### Phase 1: Setup & Detection

1. **Check for existing CODEMAP.yaml**:
   - If exists: Enter UPDATE mode (skip to Phase 5)
   - If not: Enter CREATE mode (continue)

2. **Detect project type** by scanning for:
   - **Go**: `go.mod` or `*.go` files at root
   - **TypeScript/JavaScript**: `package.json`, `tsconfig.json`
   - **Python**: `pyproject.toml`, `setup.py`, `requirements.txt`, `*.py` at root
   - **Unknown**: Fall back to directory-only analysis

3. **Build ignore list**:
   ```
   node_modules/, vendor/, .git/, dist/, build/, __pycache__/,
   .venv/, venv/, .tox/, .pytest_cache/, coverage/, .next/
   ```

4. **Scan directory structure**:
   - Identify top-level packages/directories as candidate modules
   - Skip ignored directories
   - Note: `cmd/`, `internal/`, `pkg/`, `src/`, `lib/` are structural - look inside them

### Phase 2: Symbol Extraction

For each candidate module, extract symbols based on detected language:

**Go:**
```
High-score entry points:
├── func main()
├── Exported functions in *_handler.go, *_server.go, *_api.go
├── func (h *Handler) ServeHTTP(...)
├── func New*(...) - constructors
└── Exported functions with http.Handler, gin.Context, echo.Context params

Key types:
├── Exported struct definitions
├── type X interface { ... }
└── Type aliases in models/, types/, domain/
```

**TypeScript/JavaScript:**
```
High-score entry points:
├── export default function/class
├── export { X } from (re-exports in index.ts)
├── Functions in routes/, handlers/, controllers/, pages/, api/
├── React components (function X() with JSX return)
└── Express/Fastify route handlers

Key types:
├── export interface X
├── export type X
└── export class X
```

**Python:**
```
High-score entry points:
├── if __name__ == "__main__"
├── @app.route, @router.get/post (FastAPI, Flask decorators)
├── Functions in views.py, api.py, routes.py, handlers.py
├── class X(APIView) - Django REST
└── def create/read/update/delete - CRUD patterns

Key types:
├── @dataclass classes
├── class X(BaseModel) - Pydantic
├── class X(models.Model) - Django
└── TypedDict definitions
```

**Unknown language:**
- Skip symbol extraction
- Use directory names as modules
- Mark all modules for clarification

### Phase 3: Analysis & Grouping

1. **Group symbols by module** using directory/package boundaries

2. **Score entry points**:
   - High: handlers, routers, main, public API
   - Medium: exported types, interfaces, factories
   - Low: internal helpers (exclude from map)

3. **Detect dependencies** from import statements:
   - Build `depends_on` list for each module
   - Only include internal project dependencies

4. **Identify ambiguities** requiring clarification:
   - Modules with no clear entry points
   - Generic names: `utils/`, `helpers/`, `common/`, `shared/`
   - Mixed concerns (unclear single purpose)
   - Multiple valid groupings possible

5. **Check for specs** in `specs/` directory:
   - List available spec directories for linking

### Phase 4: Enrichment (Interactive)

**For each module, one question at a time:**

1. **Clear modules** (obvious purpose, clear entry points):
   - Present auto-generated description
   - Ask: `"Module 'authentication': User login and session management. Is this accurate? [yes/edit]"`
   - If edit: Accept user's description

2. **Ambiguous modules**:
   - Ask: `"What is the purpose of 'internal/utils/'? [describe or skip]"`
   - If skip: Exclude from CODEMAP

3. **Spec linking** (if specs/ exists):
   - For each module ask: `"Link 'authentication' to a spec? [list: specs/001-auth, specs/003-sessions, skip]"`

**Important:** Ask ONE question, wait for response, then ask next question.

### Phase 5: Update Mode (if CODEMAP.yaml exists)

1. **Load existing CODEMAP.yaml**

2. **Run Phase 2-3** on current codebase

3. **Compute diff**:
   - New modules detected
   - Removed modules (directory no longer exists)
   - New entry points in existing modules
   - Removed entry points (symbol no longer exists)
   - Changed dependencies

4. **Sequential validation** - one change at a time:
   ```
   → "New module detected: 'notifications' - Push and email notifications. Add it? [yes/no/edit]"
   → "Module 'legacy' no longer exists in codebase. Remove from map? [yes/no]"
   → "New entry point in 'auth': internal/auth/oauth.go:RefreshToken. Add it? [yes/no]"
   → "Entry point removed: internal/jobs/old.go:DeprecatedWorker. Remove? [yes/no]"
   ```

5. **Preserve user edits**: Don't overwrite manually-added descriptions or custom fields

### Phase 6: Output

1. **Generate CODEMAP.yaml**:

```yaml
# CODEMAP.yaml - Semantic code map for LLM navigation
# Generated: 2025-01-20T10:30:00Z
# Run /trellis.codemap to update

version: "1.0"
generated: "2025-01-20T10:30:00Z"
project:
  name: "project-name"
  type: "go"
  root: "."

modules:
  authentication:
    description: "User login, session management, JWT validation"
    entry_points:
      - internal/auth/handler.go:LoginHandler
      - internal/auth/handler.go:LogoutHandler
      - internal/auth/middleware.go:RequireAuth
    key_types:
      - internal/auth/session.go:Session
      - internal/auth/claims.go:JWTClaims
    interfaces:
      - internal/auth/provider.go:AuthProvider
    tests: internal/auth/*_test.go
    depends_on: [config, database]
    spec: specs/003-authentication/

  job_queue:
    description: "Background job processing with persistence and retry"
    entry_points:
      - internal/jobs/queue.go:Enqueue
      - internal/jobs/queue.go:EnqueueWithDelay
      - internal/jobs/worker.go:Start
    interfaces:
      - internal/jobs/store.go:JobStore
    depends_on: [database, config]
```

2. **Display summary**:
   ```
   ═══════════════════════════════════════════════════════════
   CODEMAP GENERATED
   ═══════════════════════════════════════════════════════════

   Created: CODEMAP.yaml

   SUMMARY:
   • Modules: 8
   • Entry points: 23
   • Key types: 12
   • Interfaces: 4
   • Linked specs: 3

   NEXT STEPS:
   • Review CODEMAP.yaml for accuracy
   • Commit: git add CODEMAP.yaml && git commit -m "Add code map"
   • Update after changes: /trellis.codemap
   ═══════════════════════════════════════════════════════════
   ```

## User Arguments

- `--update`: Force update mode even if no changes detected
- `--no-interactive`: Skip enrichment questions, use auto-generated descriptions
- `--language <lang>`: Override detected language (go, typescript, python)
- `--include <pattern>`: Include additional directories (glob pattern)
- `--exclude <pattern>`: Exclude directories (in addition to defaults)
- `--no-specs`: Skip spec linking questions
- `--json`: Output analysis as JSON instead of YAML

## Error Handling

**No source code found:**
```
No source code detected in this directory.
Supported: Go, TypeScript/JavaScript, Python
For other languages, create CODEMAP.yaml manually.
```

**Ambiguous project type:**
```
Multiple project types detected: Go, TypeScript
Which should be primary? [go/typescript]
```

**Parse errors:**
```
Warning: Could not parse internal/broken/file.go - skipping
Continuing with other files...
```

## Notes

- CODEMAP.yaml should be committed to the repository
- The file is designed to be human-readable and manually editable
- `/trellis.implement` will suggest updates after implementation sessions
- Keep it compact: exclude modules with no meaningful entry points
- Prefer fewer, high-quality entries over comprehensive but noisy listings
