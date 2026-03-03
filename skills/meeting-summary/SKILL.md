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

### Step 2: Audience and Tone

Ask who the summary is for:

> "Who's the audience for this summary — the same folks who were in the meeting, or will this go to leadership or a broader team too?"

Use the answer to calibrate the output:
- **Same participants** — conversational tone, more detail, focus on action items and decisions.
- **Leadership / executive audience** — concise, outcomes-focused, minimal process detail.
- **Broader team** — add more context and background since recipients weren't in the room.

If the user doesn't have a strong preference, default to "same participants" tone.

---

### Step 3: Calendar Event

Ask the user to identify the meeting. Accept any of the following:

> "Which calendar event is this? You can share the link, or just tell me the meeting name and approximate date and I'll look it up."

**If the user provides a link:**
- Extract the event ID from the URL
- Use Google Calendar MCP to fetch event details

**If the user provides a name/date:**
- Use `get_events` with a `query` parameter to search for the meeting
- If multiple matches, present them and ask the user to pick the right one

**From the event, extract:**
- Title, date/time, attendees (names and emails), description/agenda

Confirm what you found:
> "I found {N} attendees and the following agenda: {summary}. Look right?"

If the user doesn't have a calendar event, ask them to list participants manually.

---

### Step 4: Notes and Transcript

Ask for meeting notes and transcript in a single question:

> "Do you have any meeting notes, a transcript, or both? You can paste them here or share a Google Drive/Docs link."

Accept any combination:
- **Inline text** — pasted directly into the chat
- **Google link** — fetch content via Google Drive/Docs MCP
- **Both** — use the transcript for completeness and the notes for editorial emphasis
- **Neither** — that's fine, proceed with what the user told you in Step 1

---

### Step 5: Decisions

Ask about decisions made:

> "What decisions were made during this meeting, and who made them? For example: 'We decided to go with vendor X — Sarah approved.'"

Collect each decision with the decision-maker. If the user says no decisions were made, that's fine — the Decisions section will note "No formal decisions were made in this meeting."

---

### Step 6: Action Items

Ask about action items:

> "What action items came out of the meeting? For each one, who's responsible and is there a due date?"

Collect structured data:
- Action description
- Owner
- Due date (if known)

If the user mentions Jira tickets, project codes, or document links, include them as-is.

---

### Step 7: Follow-up and Recording

Ask about next steps and, if relevant, a recording:

> "Any follow-up meetings scheduled or next steps to call out? And was this meeting recorded — should I include a link?"

If the user provides a recording link, include it in the Overview section of the output.

**Visual capture from recording:** If the user mentions that the meeting included visual content worth capturing (a demo, architecture diagram, slide walkthrough, whiteboard sketch, etc.), ask:

> "Want me to grab some screenshots from the recording? I can open the video and capture key moments — like the demo or any diagrams that were shared."

If the user agrees:
1. Open the recording URL in the browser (supports Google Meet recordings, Loom, YouTube, Vimeo, and most hosted video players).
2. Ask the user which moments to capture, or if they'd prefer you scan through and pick the most relevant visuals.
3. Play/scrub through the video, pause at key moments, and take screenshots.
4. Save screenshots to the workspace folder as `meeting-{slug}-capture-{N}.png`.
5. Reference the screenshots in the **Detailed Notes** section of the summary with descriptive captions (e.g., "Architecture diagram presented by Sarah — see screenshot below").
6. If the final delivery is a Gmail draft, attach the screenshots. If it's a Google Doc, insert the images inline.

If the video is behind authentication or can't be opened, let the user know and ask if they can share specific screenshots manually instead.

---

### Step 8: Clarification

If anything from the previous steps is ambiguous or incomplete, ask **one clarifying question at a time** until you have a clear picture:

> "You mentioned {topic} — could you clarify {specific question}?"

If everything is clear, skip this step.

---

### Step 9: Confirm and Generate

Before generating, present a brief summary of what you'll cover:

> "Got it. I'll write up a summary covering {key topics}, {N} decisions, and {N} action items for {audience}. Anything missing before I generate it?"

Wait for approval, then generate the summary as a **markdown artifact** — write the file to the workspace folder so the user can view it directly. Name it `meeting-summary-{YYYY-MM-DD}-{slug}.md` where `{slug}` is a lowercase-hyphenated short name derived from the meeting title.

After generating, present a link to the file and ask for feedback:

> "Here's the summary — [view it here](link). Let me know if you'd like any changes."

If the user requests edits, make them and present again.

---

### Step 10: Delivery (On Request)

After the user approves the summary:

- **Gmail draft** — If the user asks, create a Gmail draft addressed to all attendees from the calendar event. Use the meeting summary as the email body (convert markdown to HTML with `body_format: "html"` for proper formatting). Confirm before creating: "I'll create a Gmail draft to {N} recipients with subject '{subject}'. Go ahead?"
- **Google Doc** — If the user provides a Google Doc link, append the summary to that document. Confirm before writing: "I'll append this summary to the Google Doc at {link}. Go ahead?"
- **Neither** — The markdown file in the workspace is the deliverable.

---

## Email Format

Use this format for the generated summary. Adjust tone based on the audience identified in Step 2.

```markdown
**Subject:** Meeting Summary: {Meeting Title} — {Date}

Hi all,

Here's a recap of our {meeting title} on {date}.

## Overview

{2-4 paragraph summary of what was discussed and the key outcomes. Lead with the most important points. Write in plain language — no jargon unless it was used in the meeting. If a recording exists, mention it here: "A recording of this meeting is available [here](link)."}

{For executive audiences: keep this to 1-2 paragraphs focused on outcomes and decisions. For broader team audiences: add context about why the meeting happened and what background is relevant.}

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

{For executive audiences: keep this section short or omit it entirely — they want the top-line, not the play-by-play. For same-participant audiences: be thorough. For broader teams: include enough context that someone who wasn't there can follow along.}
```

### Formatting Rules

- **Subject line:** Always "Meeting Summary: {Title} — {Month Day, Year}"
- **Greeting:** "Hi all," — keep it simple
- **Overview:** 2-4 paragraphs max (1-2 for executive audiences). Lead with outcomes, not process.
- **Decisions:** Include the person who made or approved each decision. If pulled from a group consensus, say so.
- **Action Items:** Always a table. Include due dates when known, "TBD" when not. If the user mentioned ticket numbers or links, include them in the action description.
- **Follow-up:** Bulleted list. Include dates if known.
- **Detailed Notes:** The longest section. Organize by topic. Be thorough but not verbose — synthesize, don't transcribe. For executive audiences, abbreviate or omit.
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
*Last updated: 2026-03-03*
