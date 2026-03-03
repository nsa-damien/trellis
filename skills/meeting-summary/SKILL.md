---
name: meeting-summary
description: >
  Generate meeting summary emails from a guided interview. Use when anyone mentions
  "meeting summary", "summarize the meeting", "meeting recap", "meeting notes email",
  or asks to create a summary of a meeting for participants. Interviews for context,
  pulls participants from Google Calendar, and produces a professional summary email.
  Do NOT use for general note-taking or non-meeting summaries.
---

# Meeting Summary Generator

Generate professional meeting summary emails through a guided interview. Ask questions one at a time, pull participant info from Google Calendar, accept notes and transcripts inline or via Google links, and produce a ready-to-send summary.

---

## Prerequisites

Before starting, verify:

1. **Google Calendar access** — The user must have a working Google Calendar connection (Google Workspace MCP or equivalent). If not available, you can still proceed but must ask the user to provide the participant list manually.
2. **Google Drive access** (optional) — Needed only if the user provides Google Drive links to notes, transcripts, or wants to write the summary to a Google Doc.
3. **Gmail access** (optional) — Needed only if the user requests a Gmail draft.

If a prerequisite is missing, inform the user and offer to continue with reduced functionality (e.g., manual participant entry instead of Calendar lookup).

---

## Process

### Step 1: Greeting and Overview

Start by asking the user for a high-level overview:

> "What meeting are we summarizing? Give me the big picture — what was the agenda and what were the key outcomes?"

Wait for the response before continuing. Do not ask multiple questions at once.

---

### Step 2: Calendar Event

Ask for the Google Calendar event link:

> "Can you share the link to the calendar invitation? I'll pull the participant list and agenda from it."

Once you receive the link:
- Extract the event ID from the URL
- Use the Google Calendar MCP to fetch event details
- Extract: title, date/time, attendees (names and emails), description/agenda
- Confirm what you found: "I found {N} attendees and the following agenda: {summary}. Look right?"

If the user doesn't have a link, ask them to list participants manually.

---

### Step 3: Meeting Notes

Ask for meeting notes:

> "Do you have meeting notes to share? You can paste them here or give me a Google Drive/Docs link."

Accept either:
- **Inline text** — pasted directly into the chat
- **Google link** — fetch the content via Google Drive/Docs MCP

If the user has no notes, that's fine — move on. Notes are helpful but not required.

---

### Step 4: Transcript

Ask for the transcript:

> "Do you have a transcript of the meeting? Same deal — paste it or share a Google link."

Accept either format. Transcripts are optional. If the user provides both notes and a transcript, use the transcript for completeness and the notes for editorial emphasis.

---

### Step 5: Video Recording (Conditional)

Only ask this if the meeting content suggests a recording would be valuable (e.g., a demo was given, visual content was shared, or the user mentioned recording it):

> "Was this meeting recorded? If there's a link to the recording, I can include it in the summary for anyone who missed it."

If not relevant, skip this step entirely.

---

### Step 6: Decisions

Ask about decisions made:

> "What decisions were made during this meeting, and who made them? For example: 'We decided to go with vendor X — Sarah approved.'"

Collect each decision with the decision-maker. If the user says no decisions were made, that's fine — the Decisions section will note "No formal decisions were made in this meeting."

---

### Step 7: Action Items

Ask about action items:

> "What action items came out of the meeting? For each one, who's responsible and is there a due date?"

Collect structured data:
- Action description
- Owner
- Due date (if known)

If the user mentions Jira tickets, project codes, or document links, include them as-is.

---

### Step 8: Follow-up

Ask about next steps:

> "Any follow-up meetings scheduled or next steps to call out? For example, a follow-up call next week or a deliverable due by a certain date."

---

### Step 9: Clarification

If anything from the previous steps is ambiguous or incomplete, ask **one clarifying question at a time** until you have a clear picture. For each question, suggest the approach most aligned with best practices:

> "You mentioned {topic} — could you clarify {specific question}? Typically in these situations, {best practice suggestion}."

---

### Step 10: Confirm Understanding

Before generating, present a summary of everything you've collected:

> "Here's what I have:
> - **Meeting:** {title} on {date}
> - **Participants:** {count} attendees
> - **Key outcomes:** {brief list}
> - **Decisions:** {count}
> - **Action items:** {count}
> - **Follow-ups:** {list}
>
> Ready for me to generate the summary?"

Wait for explicit approval before proceeding.

---

### Step 11: Generate Summary

Generate the meeting summary email using the format below. Write to `tmp/meeting-summary-{YYYY-MM-DD}-{slug}.md` where `{slug}` is a lowercase-hyphenated short name derived from the meeting title.

After generating, present the full email content to the user for review.

> "Here's the summary. Review it and let me know if you'd like any changes."

If the user requests edits, make them and present again.

---

### Step 12: Delivery (On Request)

After the user approves the summary:

- **Gmail draft** — If the user asks, create a Gmail draft addressed to all attendees from the calendar event. Use the meeting summary as the email body. Confirm before creating: "I'll create a Gmail draft to {N} recipients with subject '{subject}'. Go ahead?"
- **Google Doc** — If the user provides a Google Doc link, append the summary to that document. Confirm before writing: "I'll append this summary to the Google Doc at {link}. Go ahead?"
- **Neither** — The markdown file in `tmp/` is the deliverable. Let the user know where it is.

---

## Email Format

Use this format for the generated summary. The tone is professional but conversational — clear and direct, not stuffy.

```markdown
**Subject:** Meeting Summary: {Meeting Title} — {Date}

Hi all,

Here's a recap of our {meeting title} on {date}.

## Overview

{2-4 paragraph summary of what was discussed and the key outcomes. Lead with the most important points. Write in plain language — no jargon unless it was used in the meeting. If a recording exists, mention it here: "A recording of this meeting is available [here](link)."}

## Decisions

{Bulleted list of decisions with who made/approved them. If no decisions were made:}
{- No formal decisions were made in this meeting.}

- {Decision description} — {Person who decided/approved}

## Action Items

| Action | Owner | Due |
|--------|-------|-----|
| {Task description} | {Person} | {Date or "TBD"} |

## Follow-up

- {Next meeting, scheduled deliverable, or follow-up step}

---

## Detailed Notes

{Comprehensive synthesis of the meeting content. This section is longer and more detailed than the overview. Organize by topic or agenda item. Include relevant context, discussion points, and nuance that didn't make it into the overview. If a transcript was provided, this section should capture the substance without being a verbatim dump.}
```

### Formatting Rules

- **Subject line:** Always "Meeting Summary: {Title} — {Month Day, Year}"
- **Greeting:** "Hi all," — keep it simple
- **Overview:** 2-4 paragraphs max. Lead with outcomes, not process.
- **Decisions:** Include the person who made or approved each decision. If pulled from a group consensus, say so.
- **Action Items:** Always a table. Include due dates when known, "TBD" when not. If the user mentioned ticket numbers or links, include them in the action description.
- **Follow-up:** Bulleted list. Include dates if known.
- **Detailed Notes:** The longest section. Organize by topic. Be thorough but not verbose — synthesize, don't transcribe.
- **No emojis** unless the user explicitly requests them.
- **References:** Only include links to tickets, documents, or recordings that the user explicitly mentioned. Do not look up or infer references.

---

## Examples

**Trigger phrases:**
- "Summarize that meeting"
- "Generate a meeting summary"
- "I need a recap email for the team"
- "Meeting summary for the call we just had"
- "/meeting-summary"

**Example output subject:** `Meeting Summary: Q1 Planning Review — March 3, 2026`

---

*Skill created: 2026-03-03*
