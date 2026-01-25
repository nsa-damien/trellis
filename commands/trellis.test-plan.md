---
description: Generate manual test file and test plan documentation for a feature specification
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

2. **Load feature context**:
   - **REQUIRED**: Read spec.md for user stories and acceptance criteria
   - **REQUIRED**: Read plan.md for tech stack and architecture
   - **IF EXISTS**: Read tasks.md, data-model.md, contracts/, research.md, quickstart.md

3. **Check for beads integration** (optional):
   - Check if `FEATURE_DIR/beads-mapping.json` exists
   - If NOT found: Display "No beads integration found. Proceeding with spec-based test generation." and continue to step 4
   - If found: Load mapping, verify beads accessible (`bd info`), verify root epic exists (`bd show [ROOT_EPIC_ID]`)
     - **Get current beads state**:
     - Run: `bd show [ROOT_EPIC_ID]`, `bd ready`, `bd blocked`, `bd stats` (all with --json)
     - Build task status map: completed, in_progress, ready (unblocked), blocked
     - Display progress table showing phases, completion counts, ready work, and blocked tasks

4. **Detect tech stack** from plan.md:
   - Primary language (Go, Python, TypeScript, etc.)
   - Frameworks, libraries, and external services
   - Configuration file format (YAML, JSON, TOML, etc.)

5. **Detect application configuration**:
   - Search for existing app config files (e.g., `config.yaml`, `config.json`, `settings.json`, `.env`)
   - Note the config file path and format for use in generated tests
   - If no app config found, note this for the settings.json generation

6. **Create tests directory**: `mkdir -p FEATURE_DIR/tests`

7. **Generate settings.json** at `FEATURE_DIR/tests/settings.json`:

   Include ONLY test-specific variables NOT available in the application config:
   - Test timeouts, retry counts
   - Test data identifiers (user IDs, resource IDs for testing)
   - Feature flags specific to testing
   - Mock service URLs (if different from app config)

   **Do NOT include** values already in app config:
   - API endpoints, base URLs (use app config)
   - Authentication credentials (use app config)
   - Standard service configuration (use app config)

   **Format**:
   ```json
   {
     "$schema": "https://json-schema.org/draft/2020-12/schema",
     "$comment": "Test-specific settings. App config provides base credentials and endpoints.",
     "testTimeout": 30,
     "testUserId": "test-user-123",
     "enableVerboseLogging": true
   }
   ```

8. **Generate manual test file** at `FEATURE_DIR/tests/manual.{ext}`:

   Use the language detected from plan.md (`.go`, `.py`, `.ts`, `.js`).

   **Required components**:

   - **Header comment**: Feature name, run command, config flag usage
   - **Command-line flag**: `--config <path>` to specify application config file path
   - **Configuration loading** (in priority order):
     1. Application config from `--config` flag path (required for credentials/endpoints)
     2. `settings.json` in tests directory for test-specific overrides
     3. Print clear usage message if `--config` not provided or file not found
   - **Logging transport**: Wrap HTTP client to log ALL requests/responses to timestamped file
   - **Sensitive data masking**: Mask passwords, tokens, session IDs, API keys in logs
   - **Log file**: Write to `FEATURE_DIR/tests/manual_test_YYYYMMDD_HHMMSS.log`
   - **Test functions**: One function per test case derived from test-plan.md (if exists) or spec.md
   - **Full workflow test**: End-to-end test exercising complete feature
   - **Simple results output**: Print one line per test with PASS/FAIL and failure reason

   **Output format** (simple, scannable):
   ```
   TestName1                    PASS
   TestName2                    PASS
   TestName3                    FAIL: expected status 200, got 404
   TestName4                    FAIL: timeout after 30s
   TestName5                    PASS

   ----------------------------------------
   Results: 3 passed, 2 failed, 5 total
   ```

   **Log file** (detailed, for debugging failures):
   ```
   ================================================================================
   TEST: [Test Name]
   TIME: 2024-01-15T10:30:45Z
   ================================================================================

   --- REQUEST ---
   POST /api/v1/endpoint HTTP/1.1
   Host: api.example.com
   Content-Type: application/json
   Authorization: Bearer [MASKED]

   {"key": "value"}

   --- RESPONSE ---
   HTTP/1.1 200 OK
   Content-Type: application/json

   {"result": "success"}

   --- DURATION: 150ms ---
   ================================================================================
   ```

   **Go pattern**: Use `//go:build ignore` tag, `flag` package for `--config`, implement `http.RoundTripper` for logging.

   **Python pattern**: Use `argparse` for `--config`, `requests` with custom session logging or `httpx` with event hooks.

   **TypeScript pattern**: Use `commander` or `yargs` for `--config`, `axios` interceptors for logging.

9. **Generate USAGE.md** at `FEATURE_DIR/tests/USAGE.md`:

   Brief instructions covering:
   - Prerequisites (runtime, dependencies)
   - Configuration: path to application config file, optional settings.json customization
   - Run command with `--config` flag (e.g., `go run tests/manual.go --config /path/to/app/config.yaml`)
   - Output: console shows simple PASS/FAIL per test, log file has full request/response details

10. **Generate test-plan.md** at `FEATURE_DIR/test-plan.md` (if not exists):

    **Required sections**:

    - **Header**: Feature name, version, created date, status
    - **Quick Start**: Run command with `--config` flag for manual tests
    - **Test Environment Setup**: Prerequisites, app config requirements, test data needs
    - **Automated Test Coverage**: Table of test files with descriptions and counts
    - **Manual Verification Checklist**: For each user story, checkbox items with Setup/Action/Expected/Verify
    - **Feature Testing Scenarios**: Happy path workflow, error recovery scenarios
    - **Integration Test Commands**: Full command with `--config` flag
    - **Notes**: Known limitations, test data requirements, coverage targets

    **Format**: Use markdown with checkbox lists (`- [ ]`) for verification items, code blocks for examples, tables for test file inventory.

11. **Validation and reporting**:

    Display completion summary:
    - Files created (manual.{ext}, USAGE.md, settings.json, and optionally test-plan.md)
    - Number of test functions generated
    - Number of test cases covered
    - Detected app config file (if found)
    - Next steps: run with `--config /path/to/app/config`

## User Arguments

- `--dry-run`: Show what would be generated without creating files
- `--lang [go|python|typescript|javascript]`: Override auto-detected language
- `--minimal`: Generate minimal test structure without full documentation
- `--skip-test-plan`: Skip generating test-plan.md if it already exists or is not needed

## Generated Test Arguments

The generated manual test file accepts:
- `--config <path>`: **Required.** Path to application config file (provides credentials, API endpoints)
- `--verbose`: Show detailed output instead of simple PASS/FAIL lines

## Output Structure

```
FEATURE_DIR/
├── test-plan.md              # Generated test documentation (if not exists)
└── tests/
    ├── manual.{ext}          # Generated test runner (accepts --config flag)
    ├── settings.json         # Test-specific settings (not app credentials)
    ├── USAGE.md              # Instructions for running tests
    └── manual_test_*.log     # Generated at runtime (detailed request/response logs)
```

## Notes

- Generated tests should be reviewed and customized for project-specific needs
- Console output is simple PASS/FAIL for easy scanning; log file has full details for debugging
- Sensitive data (passwords, tokens, API keys) is automatically masked in logs for safe sharing
- Test files use build tags or similar to exclude from normal compilation
- Application config (via `--config` flag) provides credentials and API endpoints
- `settings.json` is only for test-specific settings not in the application config
