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
   - Environment configuration approach (.env files)

5. **Detect configuration approach**:
   - Check if the application has a default config (e.g., `config.yaml`, `config.json`, hardcoded defaults)
   - Check for existing `.env` file at **project root** (not feature directory)
   - If application can be configured via code defaults, use those
   - Otherwise, plan to use `.env` file at project root for configuration

6. **Create tests directory**: `mkdir -p FEATURE_DIR/tests`

7. **Generate .env.example** at `FEATURE_DIR/tests/.env.example`:

   Include all environment variables needed to run the tests:
   - API endpoints, base URLs
   - Authentication credentials (with placeholder values)
   - Test-specific configuration
   - Any variables referenced in spec.md or plan.md

   **Format**:
   ```
   # Required: API Configuration
   API_BASE_URL=https://api.example.com
   API_KEY=your-api-key-here

   # Optional: Test Configuration
   TEST_TIMEOUT=30
   LOG_LEVEL=debug
   ```

8. **Generate manual test file** at `FEATURE_DIR/tests/manual.{ext}`:

   Use the language detected from plan.md (`.go`, `.py`, `.ts`, `.js`).

   **Required components**:

   - **Header comment**: Feature name, run command, required env vars, log file location
   - **Configuration loading** (in priority order):
     1. Application default config if usable for testing
     2. `.env` file at **project root** (standard location)
     3. OS environment variables as fallback
     4. Print clear usage message if required config is missing
   - **Logging transport**: Wrap HTTP client to log ALL requests/responses to timestamped file
   - **Sensitive data masking**: Mask passwords, tokens, session IDs, API keys in logs
   - **Log file**: Write to `FEATURE_DIR/tests/manual_test_YYYYMMDD_HHMMSS.log`
   - **Test functions**: One function per test case derived from test-plan.md (if exists) or spec.md
   - **Full workflow test**: End-to-end test exercising complete feature
   - **Results summary**: Print PASS/FAIL per test, summary count, exit non-zero on failure

   **Log format for API calls** (for troubleshooting):
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

   **Go pattern**: Use `//go:build ignore` tag, implement `http.RoundTripper` for logging, use `httputil.DumpRequestOut`/`DumpResponse` for full request/response capture.

   **Python pattern**: Use `requests` library with custom session logging, or `httpx` with event hooks.

   **TypeScript pattern**: Use `axios` interceptors or custom `fetch` wrapper for logging.

9. **Generate USAGE.md** at `FEATURE_DIR/tests/USAGE.md`:

   Brief instructions covering:
   - Prerequisites (runtime, dependencies)
   - Configuration (copy `.env.example` to project root, fill in values)
   - Run command (e.g., `go run tests/manual.go`)
   - Output locations (console summary, log file path)

10. **Generate test-plan.md** at `FEATURE_DIR/test-plan.md` (if not exists):

    **Required sections**:

    - **Header**: Feature name, version, created date, status
    - **Quick Start**: Environment setup commands, run command for manual tests
    - **Test Environment Setup**: Prerequisites, test data requirements, dependencies
    - **Automated Test Coverage**: Table of test files with descriptions and counts
    - **Manual Verification Checklist**: For each user story, checkbox items with Setup/Action/Expected/Verify
    - **Feature Testing Scenarios**: Happy path workflow, error recovery scenarios
    - **Integration Test Commands**: Full command with all env vars
    - **Notes**: Known limitations, test data requirements, coverage targets

    **Format**: Use markdown with checkbox lists (`- [ ]`) for verification items, code blocks for examples, tables for test file inventory.

11. **Validation and reporting**:

    Display completion summary:
    - Files created (manual.{ext}, USAGE.md, .env.example, and optionally test-plan.md)
    - Number of test functions generated
    - Number of test cases covered
    - Configuration source (app defaults / .env file)
    - Next steps (copy .env.example, fill in values, run tests)

## User Arguments

- `--dry-run`: Show what would be generated without creating files
- `--lang [go|python|typescript|javascript]`: Override auto-detected language
- `--minimal`: Generate minimal test structure without full documentation
- `--skip-test-plan`: Skip generating test-plan.md if it already exists or is not needed

## Output Structure

```
FEATURE_DIR/
├── test-plan.md              # Generated test documentation (if not exists)
└── tests/
    ├── manual.{ext}          # Generated test runner
    ├── .env.example          # Environment variable template
    ├── USAGE.md              # Instructions for running tests
    └── manual_test_*.log     # Generated at runtime
```

## Notes

- Generated tests should be reviewed and customized for project-specific needs
- The log file format captures ALL HTTP request/response data for debugging API integrations
- Sensitive data (passwords, tokens, API keys) is automatically masked in logs for safe sharing
- Test files use build tags or similar to exclude from normal compilation
- Configuration is loaded from project root `.env` file, not from the feature directory
- The `.env.example` serves as documentation for required configuration
