# Project Requirements Generator

Generate client-facing project requirements documents through a guided interview.

## What It Does

This skill walks you through a structured interview to capture project requirements, then produces a clear, non-technical document for client review and approval. It serves as a pre-commitment gate — the client signs off on requirements before you invest in scoping and pricing.

**Workflow:** Requirements Doc → Client Approval → SOW → Quote

## Setup

### Requirements

- **Claude Code** or **Claude Desktop**
- Google Drive access (optional — for fetching reference docs or creating output Google Docs)
- Gmail access (optional — for drafting delivery emails)

### Installation

**As a Trellis plugin skill:**
```
/trellis:project-requirements
```

**Standalone (Claude Desktop):**
1. Copy the `project-requirements/` folder into your Claude Desktop skills directory
2. Optionally configure Google Workspace MCP for delivery features

**Standalone (Claude Code):**
1. Copy `SKILL.md` to your project's `skills/project-requirements/SKILL.md`
2. Create a slash command at `.claude/commands/project-requirements.md`:

```markdown
---
description: Generate a project requirements document for client approval
---

Read and follow the skill at `skills/project-requirements/SKILL.md`.

User input (if any): $ARGUMENTS
```

## Usage

Just say:
- "Generate a PRD"
- "Write up project requirements for {client}"
- "I need a requirements doc"
- `/project-requirements`

The skill will interview you step by step, then generate a formatted document.

## Output

- **Default:** Markdown file saved as `prd-{date}-{slug}.md`
- **On request:** Google Doc, Gmail draft, or Confluence page

## Document Sections

1. Project Background
2. Deliverables
3. Assumptions
4. Out of Scope
5. Dependencies
6. Success Criteria
7. Timeline
8. Next Steps

## License

MIT
