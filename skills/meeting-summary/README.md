# Meeting Summary Generator

Generate professional meeting summary emails through a guided interview.

## What It Does

This skill walks you through a structured interview to gather meeting context, then generates a polished summary email for all participants. It pulls attendees and agenda automatically from Google Calendar.

## Setup

### Requirements

- **Claude Code** or **Claude Desktop** with Google Workspace MCP configured
- Google Calendar access (required for attendee lookup)
- Google Drive access (optional — for fetching notes/transcripts via link)
- Gmail access (optional — for creating email drafts)

### Installation

**As a Trellis plugin skill:**
```
/trellis:meeting-summary
```

**Standalone (Claude Desktop):**
1. Copy the `meeting-summary/` folder into your Claude Desktop skills directory
2. Ensure Google Workspace MCP is configured

**Standalone (Claude Code):**
1. Copy `SKILL.md` to your project's `skills/meeting-summary/SKILL.md`
2. Create a slash command at `.claude/commands/meeting-summary.md`:

```markdown
---
description: Generate a meeting summary email
---

Read and follow the skill at `skills/meeting-summary/SKILL.md`.

User input (if any): $ARGUMENTS
```

## Usage

Just say:
- "Summarize that meeting"
- "I need a meeting recap email"
- `/meeting-summary`

The skill will interview you step by step, then generate a formatted email.

## Output

- **Default:** Markdown file saved to `tmp/meeting-summary-{date}-{slug}.md`
- **On request:** Gmail draft addressed to all meeting participants
- **On request:** Append summary to a Google Doc you provide

## License

MIT
