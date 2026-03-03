---
name: sow-generator
description: >
  Generate client Statements of Work from templates. Use when anyone mentions
  "SOW", "statement of work", "new SOW", "generate SOW", or asks to create
  a client proposal or scope document. Interviews for project details, downloads
  the template from Google Drive, processes it locally, and delivers a ready
  .docx file. Do NOT use for general document editing or non-SOW documents.
---

# SOW Generator

Generate professional Statements of Work from Google Docs templates via a guided interview. Ask questions, collect details, download the template as .docx, run a local Python script to fill placeholders and apply conditional logic, and deliver a ready-to-send document.

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

1. **Google Drive access** — The user must have a working Google Drive connection (any connector: Google Workspace integration, Drive connector, etc.). If Google Drive access is not available, tell the user they need to configure it and **stop**. Do not attempt to generate without a template.
2. **Python code execution** — Must be enabled in this environment.
3. **python-docx library** — Install with `pip install python-docx` if not already available.

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

For any answer of "I don't know" on Avid fields, note the field and leave its placeholder unfilled. The script handles this automatically.

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

1. **Download the template** from Google Drive as .docx:
   - Use the Google Doc ID from the Template Registry (or user-provided override if given)
   - Export/download as .docx format
   - Save to a temporary file

2. **Install python-docx** if not already available:
   ```bash
   pip install python-docx
   ```

3. **Build the config JSON** from interview answers (see formats below).

4. **Run the generation script:**
   ```bash
   python scripts/generate_sow.py --template <downloaded_template.docx> --output "<Client> <Template Type> SOW - <Date>.docx" --config '<json>'
   ```

5. **Check the script's JSON output:**
   - `replacements_made` — how many placeholders were filled
   - `not_found` — any placeholders that were not found in the template (may indicate the template has changed)

#### Config JSON — Migration Template

```json
{
  "template": "migration",
  "client": "...",
  "reseller": "...",
  "platform": "...",
  "date": "...",
  "discovery": true
}
```

Set `"discovery": false` to exclude Exhibit 2 (Discovery & Extraction Services).

#### Config JSON — Avid Template

```json
{
  "template": "avid",
  "client": "...",
  "reseller": "...",
  "destination": "...",
  "total_data_size": "...",
  "disk_data": "...",
  "clip_count": "...",
  "lto_data": "...",
  "archive_system": "...",
  "free_storage": "...",
  "hypervisor": "Client VMWare",
  "network": "10Gb",
  "date": "..."
}
```

Valid `hypervisor` values: `Client VMWare`, `Client Proxmox`, `NSA Proxmox`
Valid `network` values: `10Gb`, `1Gb`, `Bonded 1Gb`

For "don't know" values, omit the key from the config or set it to `"don't know"` — the script will leave the placeholder text in the document.

### Step 5: Deliver

Present the result to the user:

```
SOW GENERATED:
  Document: {filename}.docx

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

Then offer to upload to Google Drive if Drive access is available.

### Step 6: Next Steps

After delivery, ask:

"Want me to upload this to Google Drive, export a PDF, or generate another SOW?"

---

## Error Handling

| Scenario | What to do |
|----------|-----------|
| No Google Drive access | Tell the user they need to configure Google Drive access and provide setup guidance. Stop — do not attempt generation without a template. |
| Template download fails | "The template may have moved. Do you have the current Google Doc link?" Prompt for a link, extract the Doc ID, and retry. |
| Placeholder not found (0 matches) | Warning: "Placeholder `#foo` was not found in the template — the template may have changed. The document was still generated." |
| python-docx not installed | Run `pip install python-docx` and retry. |
| Upload to Drive fails | Deliver the local .docx file and note that the upload failed. |

---

## Known Limitations

- **`#logo` replacement is text-only** — the script replaces the `#logo` text with the client name. Actual logo image insertion requires manual editing in the final document.
- **Document formatting is preserved** — replaced text inherits the run formatting from the original template.
- **Section removal works by paragraph** — if the template structure changes significantly, section boundaries (used for conditional removal of Exhibit 2, rental notes, and network caveats) may need updating in the script.

---

## Installation

1. Download `sow-generator.zip`
2. In Claude Desktop or claude.ai: Settings > Skills > Upload Skill
3. Ensure Google Drive access is configured
4. Say "Generate a new SOW" to start
