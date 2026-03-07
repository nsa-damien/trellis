# SOW Template Strategy: LLM-Driven Interview and Generation

## Overview

This document describes the architecture for converting SOW templates into LLM-fillable documents. The system uses a feature toggle pattern with an options index embedded in each template, enabling an interview-driven workflow where the skill collects requirements and generates a complete, client-ready SOW.

## Architecture

### Template Structure

Each SOW template Google Doc contains:

1. **Options Index** (first page) — a table listing all optional sections with shortcodes, categories, descriptions, dependencies, and variables
2. **Base Content** — sections that are always included, with `#variable` placeholders for string replacement
3. **Optional Sections** — content blocks wrapped in shortcode tags (e.g., `<AWE>...</AWE>`) that are included or removed based on interview responses

### Tag System

**String replacement variables**: `#variable_name`
- Simple search-and-replace values collected during the interview
- Examples: `#client`, `#reseller`, `#date`, `#user_count`

**Optional section tags**: `<SHORTCODE>...</SHORTCODE>`
- Wrap content blocks that may be included or excluded
- Shortcode matches the code in the options index
- May contain `#variable` placeholders that are only relevant when the section is included
- May be nested (inner sections must be resolved before outer ones)

### Options Index Schema

The options index is a table on the first page of each template:

| Code | Category | Description | Requires | Variables |
|------|----------|-------------|----------|-----------|
| CLOUD_ARCHIVE | Deploy | Third-party cloud archive storage | — | — |
| SSO | Deploy | External authentication (SSO/SAML) | — | — |
| EDIT_PROXY | Deploy | ISG-based edit proxy (mezzanine) workflow | — | — |
| VANTAGE | Deploy | Telestream Vantage transcoder config | — | — |
| AWE | Deploy | AWE workflow engine & Iconik connector | — | awe_term |
| ARCHIVE_WF | Workflow | Archive workflow consulting/design & training | — | — |
| REVIEW_WF | Workflow | Review & approval workflow | — | — |
| REMOTE_EDIT | Workflow | Remote editorial with VFS | — | — |
| CAMERA_INGEST | Workflow | Camera ingest / Telestream workflow | VANTAGE | — |
| GAMEDAY | Workflow | Gameday bundle (Ingest Extraction + DLR + EVS) | AWE | — |
| ADDL_TRAINING | Training | Additional training users/sessions | — | additional_training_users |
| SUPPORT | Support | NSA support hour block | — | hour |

**Column definitions:**
- **Code**: Shortcode used as the XML-style tag in the document body
- **Category**: Grouping for interview flow (Deploy, Workflow, Training, Support)
- **Description**: One-line summary shown during the interview
- **Requires**: Dependency — if this option is selected, the required option is auto-included
- **Variables**: Additional `#variable` placeholders inside this section that need values

### Default (always-included) sections

These are not in the options index because they are never optional:
- Base Iconik deployment and configuration
- ISG deployment (up to 2)
- Adobe Panel integration
- Iconik Agent
- Organization consulting / metadata schema
- Search configuration
- Users/Groups/ACLs
- Base workflows (storage scan, ingest)
- System and workflow documentation
- Base training curriculum
- General installation procedures
- Terms & conditions, acceptance, exhibits

## Interview Workflow

### Phase 1: Client info
Collect base variables: `#client`, `#reseller`, `#date`, `#user_count`, `#group_count`, `#acl_count`

### Phase 2: Options by category
Walk through the options index grouped by category:

1. **Deployment options** — CLOUD_ARCHIVE, SSO, EDIT_PROXY, VANTAGE, AWE
2. **Workflow options** — ARCHIVE_WF, REVIEW_WF, REMOTE_EDIT, CAMERA_INGEST, INGEST_EXTRACT, DLR, EVS
3. **Training options** — ADDL_TRAINING
4. **Support options** — SUPPORT

For each option:
- Present description
- Ask if included (yes/no)
- If yes and has variables, collect variable values
- If yes and has dependencies, auto-include prerequisites (notify user)

### Phase 3: Generation
1. Clone the template to a new document named for the client
2. Remove the options index page
3. For excluded options: delete the `<CODE>...</CODE>` blocks and their content
4. For included options: remove only the tags, keeping the content
5. Run `#variable` search-and-replace for all collected values
6. Cleanup pass: fix orphaned whitespace, empty headers, broken numbering
7. Where excluded options have a "declined" counterpart (e.g., `SUPPORT` → `SUPPORT_DECLINED`), include the declined text

## Limitations and Mitigations

### Tag integrity
If someone manually edits a tagged section and breaks a tag, the skill cannot find the section boundaries. **Mitigation**: The skill validates all tag pairs before processing and reports any broken tags.

### Nested options
Deletion order matters. Inner sections must be resolved before outer ones. **Mitigation**: The skill builds a dependency tree from the index and processes leaf nodes first.

### Post-deletion formatting
Removing sections can leave orphaned spacing or headers. **Mitigation**: A cleanup pass after all removals normalizes whitespace and removes empty structural elements.

### Template versioning
All SOW templates (Iconik U&R, CatDV U&R, CatDV Upgrade) must use the same index schema and tag conventions. **Mitigation**: This strategy document defines the standard. The skill code is template-agnostic — it reads the index from whatever template it's given.

## Implementation Order

1. Prep the Iconik U&R template (this effort) — add options index, standardize tags
2. Build the SOW generator skill to read the index and run the interview
3. Apply the same template structure to CatDV U&R and CatDV Upgrade templates
