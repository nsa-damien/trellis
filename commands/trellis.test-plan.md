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

3. **Verify and load beads integration**:
   - Check if `FEATURE_DIR/beads-mapping.json` exists
   - If NOT found: Display "No beads integration found. Run `/trellis.import` first to import tasks, or use `/speckit.implement` for standard execution." and **STOP**
   - If found: Load mapping, verify beads accessible (`bd info`), verify root epic exists (`bd show [ROOT_EPIC_ID]`)
   - **Get current beads state**:
   - Run: `bd show [ROOT_EPIC_ID]`, `bd ready`, `bd blocked`, `bd stats` (all with --json)
   - Build task status map: completed, in_progress, ready (unblocked), blocked
   - Display progress table showing phases, completion counts, ready work, and blocked tasks


4. **Detect tech stack** from plan.md:
   - Primary language (Go, Python, TypeScript, etc.)
   - Frameworks, libraries, and external services
   - Environment configuration approach (.env files)

5. **Create tests directory**: `mkdir -p FEATURE_DIR/tests`

6. **Generate manual test file** at `FEATURE_DIR/tests/manual.{ext}`:

   Use the language detected from plan.md (`.go`, `.py`, `.ts`, `.js`).

   **Required components**:

   - **Header comment**: Feature name, run command, required env vars, log file location
   - **Environment loading**: Load from `.env` file, fall back to OS env vars, print usage if missing
   - **Logging transport**: Wrap HTTP client to log ALL requests/responses to timestamped file
   - **Sensitive data masking**: Mask passwords, tokens, session IDs, API keys in logs
   - **Log file**: Write to `FEATURE_DIR/tests/manual_test_YYYYMMDD_HHMMSS.log`
   - **Test functions**: One function per user story test case from spec.md
   - **Full workflow test**: End-to-end test exercising complete feature
   - **Results summary**: Print PASS/FAIL per test, summary count, exit non-zero on failure

   **Go pattern**: Use `//go:build ignore` tag, implement `http.RoundTripper` for logging, use `httputil.DumpRequestOut` for request capture.

7. **Generate test-plan.md** at `FEATURE_DIR/test-plan.md`:

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

8. **Validation and reporting**:

   Display completion summary:
   - Files created (manual.{ext} and test-plan.md)
   - Number of test functions generated
   - Number of user stories covered
   - Next steps (review, add env vars, run tests)

## User Arguments

- `--dry-run`: Show what would be generated without creating files
- `--lang [go|python|typescript|javascript]`: Override auto-detected language
- `--minimal`: Generate minimal test structure without full documentation

## Output Structure

```
FEATURE_DIR/
├── test-plan.md              # Generated test documentation
└── tests/
    ├── manual.{ext}          # Generated test runner
    └── manual_test_*.log     # Generated at runtime
```

## Notes

- Generated tests should be reviewed and customized for project-specific needs
- The log file format captures all HTTP traffic for debugging API integrations
- Sensitive data is automatically masked in logs for safe sharing
- Test files use build tags or similar to exclude from normal compilation
