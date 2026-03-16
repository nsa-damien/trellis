---
name: iconik-sow-generator
description: |
  Generate Iconik Up and Running SOWs from template. Interviews for project details,
  copies the template, replaces placeholders, applies tag-based conditional logic
  (deploy options, workflows, support), and delivers a ready-to-review Google Doc.
license: MIT
metadata:
  user-invocable: true
  slash-command: /sow-iconik
  proactive: false
---

# Iconik Up and Running SOW Generator

Generate Iconik Up and Running Statements of Work from NSA templates via Google Docs.

## Template

| Field | Value |
|-------|-------|
| Doc ID | `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg` |
| Doc name | TEMPLATE #client Iconik Up and Running Services SOW |
| Default Drive folder | `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ` |

See also: `/sow-migration`, `/sow-catdv`, `/sow-catdv-upgrade`, `/sow-dhub`

## Process

### Step 0: Read the Template

Before doing anything else, read the template document (`1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg`) and extract:

1. **Global Variables table** — A table with columns `Variable` and `Description`. These are the `#variable` placeholders that appear throughout the document and must always be collected during the interview.

2. **Options Index table** — A table with columns `Code`, `Category`, `Description`, `Parent Tag`, `Requires`, and `Variables`. These define the conditional sections of the SOW.

Store both tables in memory. They drive the entire interview and generation process. **Do not rely on any hardcoded list of variables or options — the template is the single source of truth.**


### Step 1: Global Variables

Collect the global variables first, one at a time. These establish the basics of the SOW before any deeper context gathering.  **CRITICAL: You must only ask one question per message. Do not move to the next question until the user has answered the current one.**

| Variable | Interview Rule |
|----------|---------------|
| `#client-code` | Always ask first: "What's the client code?" (e.g., "ACME", "NBC") |
| `#client` | Always ask second: "What's the client name?" |
| `#reseller` | Always ask third: "Who's the reseller?" |
| `#date` | Ask last among globals: "What date for the SOW? Default: today" — format as full month (e.g., "March 12, 2026") |
| `#logo` | Ask: "Do you have a link to the client or project logo? If not, no worries — it can be added manually later." If a URL is provided, insert it using `insertInlineImage` during generation. If skipped, note for manual insertion at delivery. |
| *(any other)* | Ask using the Description from the Global Variables table |

### Step 2: Context Intake

After collecting global variables, gather any background context the user has available. This may take several messages.

**Start by asking:**
> "Do you have any background context for this SOW? This could be a BOM, email thread, meeting notes, requirements doc, or any other background. You can paste it here or share a link — I'll analyze each piece as you provide it."

**As the user provides context (one or more messages):**

1. **Analyze immediately** — After each piece of context, extract what you can: deployment options, support tier, quantities, project-specific details, etc. Map extracted values to the Options Index from the template.

2. **Acknowledge what you found** — Briefly confirm what you extracted from that piece. For example: *"Got it — I can see this includes AWE deployment and custom workflows. I also see 20 support hours mentioned."*

3. **Ask for more** — After acknowledging, ask: *"Do you have any additional context to share, or is that everything?"*

4. **Repeat** until the user indicates they're done providing context.

**Once context gathering is complete:**

Present a pre-filled summary of everything extracted, organized by Options categories. Clearly mark:
- Values confidently extracted
- Values that seem implied but need confirmation
- Values still missing (these will be asked in Step 3)

Only proceed to Step 3 for the remaining gaps. Skip any interview questions already answered by the context.

### Step 3: Interview

Ask **one question at a time** for any options not already resolved by the context provided in Step 2.

**Strict Rules:**
1. NEVER combine multiple questions into a single message.
2. Wait for a user response before asking the next question.
3. Every question must end with a comma (,) instead of a question mark.

If the answer to any question is "I don't know" or equivalent, leave the placeholder as-is in the document. Track unfilled placeholders for reporting at delivery.

**Build the interview from the template data:**

#### Options (by Category)

Group the Options Index rows by Category. For each category, present the options as a multi-select or yes/no question depending on count.

**Dependency enforcement:** If an option has a value in the `Requires` column, it can only be selected if the required option is also selected. If the user selects an option without its dependency, flag it and ask.

**Mutually exclusive options:** If an option's Description contains "Mutually exclusive with [OTHER]", present it as a single either/or question (e.g., "Did the client purchase an NSA support block, or is support declined?"). One of the two must always be selected.

**Option-specific variables:** If an option has a value in the `Variables` column, collect that variable when the option is selected. Ask a follow-up question for the value (e.g., if SUPPORT is selected and its Variables column says `hour`, ask "How many support hours?").

#### Destination

Ask: "Where should I save the finished SOW? Paste a Google Drive folder link, or I can use the default SOW folder."

- **If link provided:** Extract the folder ID from the URL (e.g., `https://drive.google.com/drive/folders/{FOLDER_ID}`) and use it as the destination.
- **If "default" or skipped:** Use the default folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`.

### Step 4: Confirm

Present a summary table before creating anything:

```
SOW DETAILS:
  Template:    Iconik Up and Running
  {for each global variable: label and value}

  {for each category: list selected options, or "None"}
  {for each option-specific variable: label and value}

  Date:        {date}
  Save to:     {folder name}
  Doc name:    {client-code} {client} Iconik Up and Running SOW - {date}

Ready to generate?
```

Wait for explicit confirmation before proceeding.

### Step 5: Create the Document

#### 5a. Resolve destination folder

Use the folder ID collected during the interview (either extracted from the user's link or the default `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`).

#### 5b. Copy template

Copy the template document `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg` to the destination folder with name: `{client-code} {client} Iconik Up and Running SOW - {date}`

#### 5c. Replace global variables

Replace all `#variable` placeholders from the Global Variables table with collected values. Use case-sensitive matching. Run in parallel where possible, batching in groups of 6-8 to avoid API timeouts.

Special case for `#logo`: If a logo URL was provided, find-and-replace `#logo` with a single space, then use `insertInlineImage` at that location with the provided URL. If no URL was provided, replace `#logo` with the client name as a text placeholder.

#### 5d. Replace option-specific variables

For each selected option that has a value in the `Variables` column, replace the corresponding `#variable` placeholder with the collected value. Skip any marked "don't know."

**IMPORTANT:** After replacements, verify counts in the responses. If any replacement returns 0 matches, flag it — the template may have changed.

#### 5e. Process conditional tags

Process child tags before parent tags (bottom-up). Use find-and-replace to replace tag markers with a single space (Google Docs API rejects empty-string replacements).

**For each SELECTED option:** Remove the `<TAG>` and `</TAG>` markers only. Keep all content between them.

**For each EXCLUDED option:** Remove the `<TAG>` marker, the `</TAG>` marker, and all content between them.
- For inline tags (e.g., `<AWE>AWE Deployment</AWE>` on a single line), find-and-replace the entire string with a single space.
- For block tags spanning multiple lines, use index-based deletion if the platform supports it, or iterative find-and-replace on identifiable anchor lines within the block.

**Processing rules:**

1. **Child before parent** — Always process nested tags before their parent tags.
2. **Mutually exclusive pairs** — For options marked "Mutually exclusive with [OTHER]", keep the selected one (strip tags only) and remove the excluded one (strip tags + content). One must always be kept.
3. **Parent rollup** — If a Parent Tag in the Options Index has no selected children, remove the parent tag and all its content. Check for parent tags that appear in the template but are not listed as a Code in the Options Index (e.g., `CUSTOM_WF_CHECKLIST` in Exhibit 1 that mirrors `CUSTOM_WORKFLOWS`). Apply the same rollup logic.
4. **Multi-location tags** — Some tags appear in multiple places in the template (e.g., GAMEDAY may appear both under AWE deployment items and under CUSTOM_WORKFLOWS workflow descriptions). Process all occurrences identically.

#### 5f. Remove generator reference material

Remove the following from the top of the generated document (these are for the generator, not client-facing):
- The **Options Index table** and any introductory text about it (e.g., "This table defines all optional sections...")
- The **Global Variables table** and its heading

### Step 6: Deliver

Present the result:

```
SOW GENERATED:
  Document: {client-code} {client} Iconik Up and Running SOW - {date}
  Link:     {google_doc_link}

Manual steps remaining:
  1. Review document for accuracy
  2. Send to reseller for pricing and PO
```

If the logo was not provided during the interview, add it to the manual steps:
```
  - Insert client/project logo where "#logo" placeholder text appears
```

If any placeholders were left unfilled:
```
  Unfilled placeholders (need manual entry):
    - #variable_name (description)
    - ...
```

### Step 7: Offer Next Steps

After delivery, ask:
> "Want me to export a PDF, share the doc with someone, or generate another SOW?"

## Error Handling

- **Copy fails:** Template doc ID may have changed. Read the template doc to verify.
- **Replacement returns 0:** Placeholder text may have changed in the template. Search for similar text.
- **Folder not accessible:** If the provided folder ID returns a permission error, inform the user and ask for a different link. Fall back to default folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ` if requested.
- **Permission error:** Check Google Workspace authentication.
- **API timeout:** When performing many find-and-replace operations, batch in groups of 6-8. Retry failures individually.

## Known Limitations

- `#logo` insertion via URL requires the image to be accessible (public link or shared Google Drive link). If the URL is not reachable, fall back to text placeholder.
- Multi-line find-and-replace is unreliable in Google Docs. Prefer short, unique anchor strings.
- Document formatting/styles from the template are preserved by copy, but API-inserted text comes in as plain text.
- Removing lines by replacing with a single space leaves a blank line (Google Docs API rejects empty-string replacement).

---

*Skill created: 2026-03-12*
