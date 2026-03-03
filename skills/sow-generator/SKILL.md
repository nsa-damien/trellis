---
name: sow-generator
description: >
  Generate client Statements of Work from templates. Use when anyone mentions
  "SOW", "statement of work", "new SOW", "generate SOW", or asks to create
  a client proposal or scope document. Interviews for project details, duplicates
  the template in Google Drive, fills placeholders and applies conditional logic
  directly via the Google Docs API. Do NOT use for general document editing or non-SOW documents.
---

# SOW Generator

Generate professional Statements of Work from Google Docs templates via a guided interview. Ask questions, collect details, duplicate the template in Google Drive, fill placeholders and apply conditional logic using the Google Docs API, and deliver a ready-to-send Google Doc.

Two active templates are available today:
- **MAM Migration** — general media asset management platform migration
- **Avid Interplay Migration** — Avid-specific migration to a new MAM

Two more are coming soon:
- Iconik Up and Running
- CatDV Up and Running

---

## Template Registry

| Template | Google Doc ID | Status |
|----------|---------------|--------|
| MAM Migration | `1QUNVJNaSUU5MztXAQHbjWTINKCJREkT8D1Kypf6WmAA` | Active |
| Avid Interplay Migration | `1wz7hGKQ_kOfKOrKxwk6AhzNNch2q4HHVOe7IxD5U3gg` | Active |
| Iconik Up and Running | `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg` | Coming soon |
| CatDV Up and Running | `13I-g12freK_Z2OjVC181Jt4rKdkHL3YP3b_-E9JXo18` | Coming soon |

Default Google Doc IDs can be overridden if the user provides a Google Doc link. On download failure, prompt the user for the current link.

---

## Prerequisites

Before starting, verify:

1. **Google Workspace MCP** — The user must have a working Google Workspace connection with Google Docs and Drive access. If not available, tell the user they need to configure it and **stop**.
2. **User's Google email** — Required for all Google Workspace API calls. Ask once at the start if not already known.

---

## Process

### Step 1: Select Template

If the user already specified a template type in their request (e.g., "generate an Avid SOW"), skip this step.

Otherwise, ask which template they need.

**Shortcut detection:**
- "Avid", "Interplay", "OP-1a", "MXF" --> Avid Interplay Migration template
- "MAM", "migration" (without Avid context) --> MAM Migration template
- "Iconik" or "CatDV" --> Inform the user those templates are not integrated yet and are coming soon

### Step 2: Interview

Ask **one question at a time**. Do not batch multiple questions together.

#### MAM Migration Template Questions (in order)

1. "What's the client name?"
2. "Who's the reseller?"
3. "What's the source MAM platform?" (Common platforms: Dalet, Reach Engine, CatDV, EditShare Flow)
4. "Does this platform require database discovery and extraction?" (Explain: this adds Exhibit 2 to the SOW for database reverse-engineering services)
5. "What date for the SOW?" (Default: today's date, formatted as full month — e.g., "March 2, 2026")

#### Avid Interplay Migration Template Questions (in order)

1. "What's the client name?"
2. "Who's the reseller?"
3. "What's the destination MAM?" (Most likely Iconik)
4. "What's the total estimated data size?"
5. "How much disk data (in TB)?"
6. "Approximately how many online clips?"
7. "Any LTO tape data?" (Size in TB, or N/A)
8. "What archive system?" (FlashNet, SDNA, other, or N/A)
9. "How much free storage does the client currently have (in TB)?"
10. "Hypervisor setup?" (Client VMWare / Client Proxmox / NSA Proxmox)
11. "Network speed?" (10Gb / 1Gb / Bonded 1Gb)
12. "What date for the SOW?" (Default: today's date)

For any answer of "I don't know" on Avid fields, note the field and skip its replacement — the placeholder text stays in the document.

Read `REFERENCE.md` (in this skill's directory) for full placeholder tables and conditional logic rules.

### Step 3: Confirm

Present a summary table before generating. **Wait for explicit approval** before proceeding.

#### Migration Confirmation Format

```
SOW DETAILS:
  Template:    MAM Migration
  Client:      {client}
  Reseller:    {reseller}
  Platform:    {platform}
  Date:        {date}
  Discovery:   Included / Excluded
  Doc name:    {client} MAM Migration SOW - {date}

Ready to generate?
```

#### Avid Confirmation Format

```
SOW DETAILS:
  Template:    Avid Interplay Migration
  Client:      {client}
  Reseller:    {reseller}
  Destination: {destination}
  Data Size:   {total_data_size}
  Disk:        {disk_data} TB
  Clips:       ~{clip_count}
  LTO:         {lto_data}
  Archive:     {archive_system}
  Free Storage:{free_storage} TB
  Hypervisor:  {hypervisor}
  Network:     {network}
  Rental:      Yes / No  (derived from hypervisor — Yes only if NSA Proxmox)
  Date:        {date}
  Doc name:    {client} Avid Interplay Migration SOW - {date}

  Unfilled (left as placeholders): {list any "don't know" items}

Ready to generate?
```

### Step 4: Generate

After the user approves, execute the following steps:

#### 4a. Duplicate the template

Use `copy_drive_file` to create a copy of the template in the user's Google Drive:
- Use the Google Doc ID from the Template Registry (or user-provided override)
- Set `new_name` to the SOW document name (e.g., "NSA MAM Migration SOW - March 2, 2026")
- Save the **new document ID** from the response — all subsequent operations use this ID

#### 4b. Fill placeholders

Run `find_and_replace_doc` calls to replace all placeholders. **Run these in parallel** for speed since they are independent.

**Migration template replacements:**

| find_text | replace_text |
|-----------|-------------|
| `#client` | Client name |
| `#reseller` | Reseller name |
| `#platform` | Source MAM platform |
| `#date` | SOW date |
| `#logo` | Client name (manual logo insertion later) |

**Avid template replacements** (in addition to #client, #reseller, #date, #logo):

| find_text | replace_text |
|-----------|-------------|
| `#destination` | Destination MAM |
| `#total_data_size` | Total data size |
| `#disk_data` | Disk data in TB |
| `#clip_count` | Online clip count |
| `#lto_data` | LTO data size or N/A |
| `#archive_system` | Archive system type |
| `#free_storage` | Free storage in TB |
| `#hypervisor` | See Hypervisor Options in REFERENCE.md |
| `#network` | See Network Options in REFERENCE.md |

For "don't know" values, **skip the replacement** — leave the `#placeholder` text in the document.

**Hypervisor replacement values:**
- Client VMWare → `Client-provided VMWare`
- Client Proxmox → `Client-provided Proxmox`
- NSA Proxmox → `NSA-provided Proxmox hardware`

**Network replacement values:**
- 10Gb → `10Gb host bus adapter (HBA)`
- 1Gb → `1Gb networking`
- Bonded 1Gb → `Bonded 1Gb connections`

#### 4c. Apply conditional logic (section removal)

After all replacements are complete, remove conditional sections. This requires finding text positions and deleting ranges.

**Migration template — Discovery excluded:**

When discovery is excluded, remove two things:
1. The deliverables reference line — use `find_and_replace_doc` to replace the line `Note: If the source {platform} system requires database discovery and extraction services, please see Exhibit 2: Discovery & Extraction Services (Optional) for more information` with empty string `""`
2. The Exhibit 2 section — use `inspect_doc_structure` (with `detailed: true`) to find the start index of "Exhibit 2: Discovery & Extraction Services (Optional)" and the end index of "[END]", then use `batch_update_doc` with a `delete_text` operation to remove that range

**Avid template — Client-provided hypervisor:**

When hypervisor is Client VMWare or Client Proxmox, use `find_and_replace_doc` to replace the line containing "Server rental fees" with empty string.

**Avid template — 10Gb network:**

When network is 10Gb, use `find_and_replace_doc` to remove these three caveat lines (replace each with empty string):
1. `Note: 1Gb networking is supported; however, this will significantly increase the overall project timeline and may result in a Change Order`
2. `NSA recommends bonded 1Gb connections minimum or installation of a 10Gb host bus adapter (HBA)`
3. `All NSA-provided systems are equipped with multiple 1Gb and 10Gb network interfaces`

#### 4d. Verify

After all operations, use `get_doc_content` to spot-check that placeholders were replaced and sections were removed correctly. Report any `#placeholder` text that remains.

### Step 5: Deliver

Present the result to the user with the Google Doc link:

```
SOW GENERATED:
  Document: {doc name}
  Link:     {Google Doc link from copy_drive_file response}

Manual steps remaining:
  1. Replace "#logo" text with actual client/project logo
  2. Review document for accuracy
  3. Send to reseller for pricing and PO
```

If there are unfilled placeholders, also show:

```
  Unfilled placeholders (need manual entry):
    - #total_data_size
    - #disk_data
    ...
```

If Discovery was excluded (Migration template):

```
  Note: Exhibit 2 (Discovery & Extraction) was removed.
```

### Step 6: Next Steps

After delivery, ask:

"Want me to move this to a specific Drive folder, export a .docx or PDF, or generate another SOW?"

---

## Error Handling

| Scenario | What to do |
|----------|-----------|
| No Google Workspace MCP | Tell the user they need to configure Google Workspace access. Stop — do not attempt generation without it. |
| Template copy fails | "The template may have moved. Do you have the current Google Doc link?" Prompt for a link, extract the Doc ID, and retry. |
| Placeholder not found (0 matches) | Warning: "Placeholder `#foo` was not found in the template — the template may have changed. The document was still generated." |
| Section removal fails | If `inspect_doc_structure` can't find section boundaries, warn the user and leave the section in place for manual removal. |
| find_and_replace returns 0 | The placeholder text may have changed in the template. Warn but continue. |

---

## Known Limitations

- **`#logo` replacement is text-only** — replaces the `#logo` text with the client name. Actual logo image insertion requires manual editing.
- **Document formatting is preserved** — `find_and_replace_doc` preserves the formatting of the original text.
- **Section removal requires index calculation** — if the template structure changes significantly, `inspect_doc_structure` may need careful analysis to find correct deletion boundaries for Exhibit 2.
- **Google Docs API only** — no local Python dependencies required. The `scripts/` directory contains a legacy local generation script as a fallback.
