---
name: project-requirements
description: >
  Generate client-facing project requirements documents through a guided interview.
  Use when anyone mentions "PRD", "project requirements", "requirements doc",
  "requirements document", "project spec", or asks to document what will be delivered
  to a client for approval. Interviews for project context and produces a clear,
  non-technical requirements document for client sign-off. Do NOT use for internal
  technical specs, developer PRDs, or architecture docs.
---

# Project Requirements Generator

Generate professional, client-facing project requirements documents through a guided interview. This document serves as a pre-commitment gate: the client reviews and approves the requirements before you invest in scoping (SOW) and pricing.

**Workflow position:** Requirements Doc → Client Approval → SOW → Quote

---

## Prerequisites

Before starting, verify:

1. **Google Drive access** (optional) — Needed if the user wants to fetch existing context documents or output to a Google Doc.
2. **Gmail access** (optional) — Needed only if the user requests a Gmail draft.

If neither is available, the skill works fine — it just produces a markdown file.

---

## Process

### Step 1: Existing Context

Start by asking if there's any existing material to work from:

> "Before we start, is there an existing discovery doc, proposal, meeting notes, or any prior documentation I should reference? You can paste it, share a Google link, or just give me the highlights."

If the user provides a link, fetch the content via Google Drive/Docs MCP. If they paste text or summarize verbally, use that as context. If they have nothing, move on.

---

### Step 2: Project Background

Ask about the why:

> "What's the project about? Tell me why the client is doing this — what problem are they trying to solve, and what's driving the timing?"

This becomes the opening section of the document. Capture:
- The business problem or opportunity
- Why now (what's driving urgency or timing)
- Any relevant context about the client's current state

---

### Step 3: Deliverables

Ask about the what:

> "What exactly will be delivered? Walk me through the concrete outputs the client will receive when this project is complete."

Press for specificity. Vague deliverables like "a new system" should be broken down into concrete items. For each deliverable, understand:
- What it is
- What it does for the client
- How the client will interact with or receive it

If the user is vague, push back:

> "Can you be more specific about {item}? The whole point of this document is to eliminate ambiguity — what exactly will the client see or receive?"

---

### Step 4: Assumptions

Ask about what's being taken as given:

> "What assumptions are we making? Things like 'the client will provide access to their existing system' or 'their data is in a usable format.' What has to be true for this project to go as planned?"

Common assumption categories to probe if the user doesn't mention them:
- Client-provided access or credentials
- Data quality or format expectations
- Existing infrastructure or systems
- Staffing or availability on the client side
- Licensing or third-party agreements

---

### Step 5: Out of Scope

Ask about what's explicitly excluded:

> "What's NOT included? This is the ambiguity killer — what might the client reasonably assume is part of this project that actually isn't?"

This is the most important section for preventing scope disputes. Push the user to think about:
- Adjacent work that's easy to confuse with the deliverables
- Future phases that aren't part of this engagement
- Maintenance, support, or training that isn't included
- Integrations or features that look related but aren't covered

If the user says "nothing comes to mind," push:

> "Think about past projects where scope creep hit you. What did clients assume was included that wasn't? That's what goes here."

---

### Step 6: Dependencies

Ask about what the client needs to provide or do:

> "What does the client need to provide or do for this project to succeed? Access, data, approvals, resources, availability for meetings — anything on their side."

Distinguish between:
- **Prerequisites** — things needed before work can start
- **Ongoing dependencies** — things needed during the project (e.g., timely feedback, test environment access)

---

### Step 7: Success Criteria

Ask about how the client will know it's done right:

> "How will the client know this project was successful? Not technical benchmarks — what value will they see? What will they be able to do that they can't do today?"

Keep this value-oriented:
- Business outcomes, not technical metrics
- "The client can now do X" not "the system responds in under 200ms"
- Tangible improvements the client will experience

---

### Step 8: Timeline

Ask about timing expectations:

> "Are there any hard deadlines or milestone dates? Events, launches, contract dates — anything that constrains the timeline?"

Capture:
- Hard deadlines and what's driving them
- Key milestones or phase boundaries
- Any blackout periods or scheduling constraints

If there are no hard deadlines, note that the timeline will be established in the SOW.

---

### Step 9: Clarification

If anything from the previous steps is ambiguous or incomplete, ask **one clarifying question at a time** until you have a clear picture:

> "You mentioned {topic} — could you clarify {specific question}?"

If everything is clear, skip this step.

---

### Step 10: Confirm and Generate

Before generating, present a summary:

> "Here's what I have:
> - **Project:** {one-line description}
> - **Deliverables:** {count} items
> - **Assumptions:** {count}
> - **Out of scope:** {count} exclusions
> - **Dependencies:** {count}
> - **Success criteria:** {count}
> - **Timeline:** {summary}
>
> Ready for me to generate the requirements document?"

Wait for explicit approval before proceeding.

---

### Step 11: Generate Document

Generate the project requirements document using the format below. Write the file to the workspace folder as `prd-{YYYY-MM-DD}-{slug}.md` where `{slug}` is a lowercase-hyphenated short name derived from the project description.

After generating, present the document to the user for review:

> "Here's the requirements doc — [view it here](link). Let me know if you'd like any changes."

If the user requests edits, make them and present again. Iterate until approved.

---

### Step 12: Delivery (On Request)

After the user approves the document:

- **Google Doc** — If the user asks, create a new Google Doc with the content. Confirm before creating: "I'll create a Google Doc titled '{title}'. Go ahead?"
- **Gmail draft** — If the user asks, create a Gmail draft with the document as the email body or as a link to the Google Doc. Confirm before creating: "I'll draft an email to {recipients} with the requirements doc. Go ahead?"
- **Confluence page** — If the user asks and has Confluence access, create a page under the appropriate client space. Confirm before creating.
- **None of the above** — The markdown file in the workspace is the deliverable.

---

## Document Format

Use this format for the generated document. The tone is professional but conversational — clear, direct, and non-technical. The audience is the client, not developers.

```markdown
# Project Requirements: {Project Name}

**Prepared for:** {Client Name}
**Prepared by:** {User's company or name}
**Date:** {Date}
**Status:** Draft — Pending Client Review

---

## Project Background

{2-3 paragraphs explaining why this project exists. What problem is the client solving? What's driving the timing? What's the current state and what needs to change? Write for the client — they should read this and think "yes, that's exactly our situation."}

---

## Deliverables

The following items will be delivered as part of this engagement:

### {Deliverable 1 Name}

{Clear, concise description of what this deliverable is and what it does for the client. 2-4 sentences. Avoid technical jargon — describe it in terms of what the client gets.}

### {Deliverable 2 Name}

{Description}

{Repeat for each deliverable}

---

## Assumptions

This project plan is based on the following assumptions. If any of these prove incorrect, scope and timeline may need to be revisited.

- {Assumption 1}
- {Assumption 2}
- {Assumption 3}

---

## Out of Scope

The following items are explicitly **not included** in this engagement. They may be addressed in a future phase or separate project.

- {Exclusion 1}
- {Exclusion 2}
- {Exclusion 3}

---

## Dependencies

The following items are required from {Client Name} for this project to proceed:

### Before Work Begins
- {Prerequisite 1}
- {Prerequisite 2}

### During the Project
- {Ongoing dependency 1}
- {Ongoing dependency 2}

---

## Success Criteria

This project will be considered successful when:

- {Criterion 1 — value-oriented, what the client can now do}
- {Criterion 2}
- {Criterion 3}

---

## Timeline

{If hard deadlines exist: describe them and what drives them.}
{If no hard deadlines: "A detailed timeline and milestone schedule will be established in the Statement of Work following approval of these requirements."}

{If milestones or phases are known, list them here.}

---

## Next Steps

1. Review this document and confirm it accurately reflects your requirements
2. Reply to confirm approval or provide feedback for revisions
3. Upon approval, we will prepare a Statement of Work with detailed scope, timeline, and pricing

---

*This document describes what will be delivered. Detailed scope, pricing, and timeline will be established in the Statement of Work following client approval of these requirements.*
```

### Formatting Rules

- **Title:** Always "Project Requirements: {Project Name}"
- **Header block:** Include client name, preparer, date, and draft status
- **Tone:** Professional but conversational. Write for the client, not for developers.
- **Jargon:** Avoid technical terms. If a technical concept must be mentioned, explain it in plain language.
- **Deliverables:** Each gets its own subsection with a clear description. Don't use bullet lists for deliverables — they deserve more than a one-liner.
- **Out of Scope:** Be explicit and specific. Vague exclusions don't prevent scope disputes.
- **Success Criteria:** Value-oriented. "The client can now do X" not "the system performs at Y."
- **Next Steps:** Always include — makes it clear what the client needs to do.
- **No emojis** unless the user explicitly requests them.
- **References:** Only include links or references the user explicitly mentioned.

---

## Examples

**Trigger phrases:**
- "Generate a PRD"
- "Write up the project requirements"
- "I need a requirements doc for the client"
- "Document what we're delivering"
- "Project requirements for {client name}"
- "/project-requirements"

**Example output title:** `Project Requirements: Acme Corp Media Migration`

---

*Skill created: 2026-03-03*
