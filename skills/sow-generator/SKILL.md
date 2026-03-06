---
name: sow-generator
description: |
  Generate client SOWs from templates. Interviews for project details, copies the template,
  replaces placeholders, applies conditional logic, and delivers a ready-to-review
  Google Doc. Use when Damien says "new SOW", "generate SOW", or "/sow".
license: MIT
compatibility: marvin
metadata:
  marvin-category: work
  user-invocable: true
  slash-command: /sow
  model: default
  proactive: false
---

# SOW Generator

Generate client Statements of Work from NSA templates via Google Docs.

## Templates

| Template | Google Doc ID | Status |
|----------|---------------|--------|
| MAM Migration | `1QUNVJNaSUU5MztXAQHbjWTINKCJREkT8D1Kypf6WmAA` | Active |
| Avid Interplay Migration | `1wz7hGKQ_kOfKOrKxwk6AhzNNch2q4HHVOe7IxD5U3gg` | Active |
| Iconik Up and Running | `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg` | Not yet integrated |
| CatDV Up and Running | `13I-g12freK_Z2OjVC181Jt4rKdkHL3YP3b_-E9JXo18` | Not yet integrated |

## Placeholder Reference — Migration Template

### Required fill-ins

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `#client` | Client company name | Acme Broadcasting |
| `#reseller` | Reseller/dealer company name | Signiant Media |
| `#platform` | Source MAM platform name | Dalet |
| `#date` | Document date | February 25, 2026 |
| `#logo` | Client or project logo | *(manual — not automated)* |

### Optional sections

| Section | Location | Default |
|---------|----------|---------|
| Exhibit 2: Discovery & Extraction Services | End of document | Exclude unless source platform requires DB reverse-engineering |

## Placeholder Reference — Avid Interplay Migration Template

### Shared fill-ins (same as Migration)

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `#client` | Client company name | Acme Broadcasting |
| `#reseller` | Reseller/dealer company name | ASG |
| `#date` | Document date | February 25, 2026 |
| `#logo` | Client or project logo | *(manual — not automated)* |

### Avid-specific fill-ins

| Placeholder | Description | Example | "I don't know" |
|-------------|-------------|---------|----------------|
| `#destination` | Destination MAM system | Iconik | Leave as `#destination` |
| `#total_data_size` | Total estimated data size | 150 TB | Leave as `#total_data_size` |
| `#disk_data` | Disk data in TB | 80 | Leave as `#disk_data` |
| `#clip_count` | Approximate online clip count | 250,000 | Leave as `#clip_count` |
| `#lto_data` | LTO tape data size | 70 TB / N/A if none | Leave as `#lto_data` |
| `#archive_system` | Archive system type | FlashNet, SDNA | Leave as `#archive_system` |
| `#free_storage` | Current free storage in TB | 40 | Leave as `#free_storage` |
| `#hypervisor` | Hypervisor setup (see options below) | Client-provided VMWare | Leave as `#hypervisor` |
| `#network` | Network speed (see options below) | 10Gb | Leave as `#network` |

### Hypervisor options (pick one)

| Answer | Replacement text | Server rental |
|--------|-----------------|---------------|
| Client VMWare | `Client-provided VMWare` | No |
| Client Proxmox | `Client-provided Proxmox` | No |
| NSA Proxmox | `NSA-provided Proxmox hardware` | Yes — keep rental note |

**Server rental logic:** If `#hypervisor` = NSA Proxmox, the "Note: Server rental fees apply when NSA-provided hardware is used" line stays as-is. If client-provided, remove the server rental note line.

### Network options and conditional text

| Answer | Replacement text | Conditional action |
|--------|------------------|--------------------|
| 10Gb | `10Gb host bus adapter (HBA)` | **Remove** the three lines after `Network:` (1Gb caveat, bonded recommendation, NSA equipment note) |
| 1Gb | `1Gb networking` | Keep all three caveat lines as-is |
| Bonded 1Gb | `Bonded 1Gb connections` | Keep all three caveat lines as-is |
| Don't know | Leave `#network` | Keep all three caveat lines as-is |

The three conditional lines after the Network placeholder:
1. `Note: 1Gb networking is supported; however, this will significantly increase the overall project timeline and may result in a Change Order`
2. `NSA recommends bonded 1Gb connections minimum or installation of a 10Gb host bus adapter (HBA)`
3. `All NSA-provided systems are equipped with multiple 1Gb and 10Gb network interfaces`

## Process

### Step 1: Select Template

If the user specified a template type in their input (e.g., "/sow migration", "/sow avid"), skip this question.
Otherwise ask:

> Which template?
> 1. **MAM Migration** — standard platform-to-platform migration
> 2. **Avid Interplay Migration** — Avid-specific with media processing, VM deployment, and infrastructure variables

Shortcut detection: If the user mentions "Avid", "Interplay", "OP-1a", or "MXF" → select Avid template.

If they ask for Iconik or CatDV Up and Running, tell them those templates
haven't been integrated into the workflow yet and offer to generate manually.

### Step 2: Interview

Ask **one question at a time**. Damien's explicit preference — no multi-question batches.

If the answer to any Avid-specific question is "I don't know" or equivalent, leave the placeholder
as-is in the document. Tell the user which placeholders remain unfilled at delivery.

#### Migration Template — Question order:

1. **Client name** — "What's the client name?"
2. **Reseller** — "Who's the reseller?"
3. **Source platform** — "What's the source MAM platform?" *(Common: Dalet, Reach Engine, CatDV, EditShare Flow)*
4. **Discovery & Extraction** — "Does this platform require database discovery and extraction? (This adds Exhibit 2 — the optional Discovery & Extraction Services scope)"
5. **Date** — "What date for the SOW? Default: today" *(Format as full month, e.g., "February 25, 2026")*
6. **Destination folder** — Use default Drive folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ` unless told otherwise.

#### Avid Interplay Template — Question order:

1. **Client name** — "What's the client name?"
2. **Reseller** — "Who's the reseller?"
3. **Destination MAM** — "What's the destination MAM? (Likely Iconik)"
4. **Total data size** — "What's the total estimated data size?"
5. **Disk data** — "How much disk data (in TB)?"
6. **Clip count** — "Approximately how many online clips?"
7. **LTO tape data** — "Any LTO tape data? (Size, or N/A if none)"
8. **Archive system** — "What archive system? (FlashNet, SDNA, other, or N/A)"
9. **Free storage** — "How much free storage does the client currently have (in TB)?"
10. **Hypervisor** — "Hypervisor setup? (Client VMWare / Client Proxmox / NSA Proxmox)"
11. **Network** — "Network speed? (10Gb / 1Gb / Bonded 1Gb)"
12. **Date** — "What date for the SOW? Default: today" *(Format as full month, e.g., "February 25, 2026")*
13. **Destination folder** — Use default Drive folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ` unless told otherwise.

### Step 3: Confirm

Present a summary table before creating anything.

**Migration:**
```
SOW DETAILS:
  Template:    MAM Migration
  Client:      {client}
  Reseller:    {reseller}
  Platform:    {platform}
  Date:        {date}
  Discovery:   Included / Excluded
  Save to:     {folder name}
  Doc name:    {client} MAM Migration SOW - {date}

Ready to generate?
```

**Avid Interplay:**
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
  Rental:      Yes / No  (derived from hypervisor)
  Date:        {date}
  Save to:     {folder name}
  Doc name:    {client} Avid Interplay Migration SOW - {date}

  Unfilled (left as placeholders): {list any "don't know" items}

Ready to generate?
```

Wait for explicit confirmation before proceeding.

### Step 4: Create the Document

1. **Find destination folder** (if not using default):
   - Use `mcp__google-workspace__search_drive_files` to find the folder
   - If multiple matches, ask which one
   - If no match, offer to use default folder

2. **Copy template**:

   *Migration:*
   ```
   mcp__google-workspace__copy_drive_file
     file_id: 1QUNVJNaSUU5MztXAQHbjWTINKCJREkT8D1Kypf6WmAA
     new_name: "{client} MAM Migration SOW - {date}"
     parent_folder_id: {folder_id}
   ```

   *Avid Interplay:*
   ```
   mcp__google-workspace__copy_drive_file
     file_id: 1wz7hGKQ_kOfKOrKxwk6AhzNNch2q4HHVOe7IxD5U3gg
     new_name: "{client} Avid Interplay Migration SOW - {date}"
     parent_folder_id: {folder_id}
   ```

3. **Replace placeholders** — run in parallel where possible. Use `match_case: true` for all.

   *Migration:*
   ```
   find_and_replace_doc: #client   → {client}
   find_and_replace_doc: #reseller → {reseller}
   find_and_replace_doc: #platform → {platform}
   find_and_replace_doc: #date     → {date}
   find_and_replace_doc: #logo     → {client}   (temporary — note for manual logo insertion)
   ```

   *Avid Interplay — batch 1 (shared placeholders):*
   ```
   find_and_replace_doc: #client   → {client}
   find_and_replace_doc: #reseller → {reseller}
   find_and_replace_doc: #date     → {date}
   find_and_replace_doc: #logo     → {client}   (temporary — note for manual logo insertion)
   ```

   *Avid Interplay — batch 2 (Avid-specific, skip any marked "don't know"):*
   ```
   find_and_replace_doc: #destination     → {destination}
   find_and_replace_doc: #total_data_size → {total_data_size}
   find_and_replace_doc: #disk_data       → {disk_data}
   find_and_replace_doc: #clip_count      → {clip_count}
   find_and_replace_doc: #lto_data        → {lto_data}
   find_and_replace_doc: #archive_system  → {archive_system}
   find_and_replace_doc: #free_storage    → {free_storage}
   find_and_replace_doc: #hypervisor      → {hypervisor replacement text}
   find_and_replace_doc: #network         → {network replacement text}
   ```

   **IMPORTANT**: After replacements, verify counts in the responses. If any replacement returns
   0 matches, flag it — the template may have changed.

4. **Apply conditional logic** (Avid template only):

   **Server rental** — If hypervisor is client-provided (VMWare or Proxmox):
   ```
   find_and_replace_doc: "Note: Server rental fees apply when NSA-provided hardware is used" → " "
   ```
   If NSA-provided, leave the note as-is.

   **Network caveats** — If network is 10Gb, remove the three caveat lines:
   ```
   find_and_replace_doc: "Note: 1Gb networking is supported; however, this will significantly increase the overall project timeline and may result in a Change Order" → " "
   find_and_replace_doc: "NSA recommends bonded 1Gb connections minimum or installation of a 10Gb host bus adapter (HBA)" → " "
   find_and_replace_doc: "All NSA-provided systems are equipped with multiple 1Gb and 10Gb network interfaces" → " "
   ```
   If network is 1Gb, Bonded 1Gb, or unknown, leave all caveats as-is.

5. **Remove excluded sections** (Migration template, if Discovery & Extraction is excluded):
   - Read the new document with `get_doc_content`
   - The section to remove starts with "Exhibit 2: Discovery & Extraction Services (Optional)"
   - It ends at "[END]" (the last line of the document)
   - Also remove the reference to Exhibit 2 in the Deliverables section:
     "Note: If the source #platform system requires database discovery..."
   - Use `find_and_replace_doc` to replace identifiable single-line anchors with empty strings
   - For multi-line removal, use `modify_doc_text` with start_index/end_index if needed
   - **Caution**: Multi-line find_and_replace is fragile in Google Docs. Prefer short, unique
     anchor strings. See Dead Ends in handoff.md for known issues.

### Step 5: Deliver

Present the result:

**Migration:**
```
SOW GENERATED:
  Document: {client} MAM Migration SOW - {date}
  Link:     {google_doc_link}

Manual steps remaining:
  1. Replace "#logo" text with actual client/project logo
  2. Review document for accuracy
  3. Send to reseller for pricing and PO
```

**Avid Interplay:**
```
SOW GENERATED:
  Document: {client} Avid Interplay Migration SOW - {date}
  Link:     {google_doc_link}

Manual steps remaining:
  1. Replace "#logo" text with actual client/project logo
  2. Review document for accuracy
  3. Send to reseller for pricing and PO
```

If any placeholders were left unfilled:
```
  Unfilled placeholders (need manual entry):
    - #total_data_size (Total Estimated Data Size)
    - #disk_data (Disk Data TB)
    ...
```

If Discovery & Extraction was excluded (Migration only):
```
  Note: Exhibit 2 (Discovery & Extraction) was removed.
        The Deliverables reference to it was also removed.
```

### Step 6: Offer Next Steps

After delivery, ask:
> "Want me to export a PDF, share the doc with someone, or generate another SOW?"

## Error Handling

- **Copy fails**: Check if template doc ID is still valid. The template may have been moved or renamed.
- **Replacement returns 0**: The placeholder text may have been changed in the template. Read the doc and search for similar text.
- **Folder not found**: Default to `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ` and tell the user.
- **Permission error**: Remind user to check Google Workspace auth. May need to re-authenticate if session expired.
- **Google Workspace timeout**: When sending many parallel find_and_replace calls, batch in groups of 6-8. Retry failures individually.

## Known Limitations

- `#logo` replacement is text-only. Actual logo insertion requires manual editing in Google Docs.
- Multi-line find_and_replace is unreliable. Always verify replacement counts.
- Document formatting/styles from the template are preserved by copy, but any text inserted via the API comes in as plain text.
- Removing lines via find_and_replace with `" "` (single space) leaves a blank line. This is a Google Docs API limitation — empty string replacement is rejected.

---

*Skill created: 2026-02-25*
*Updated: 2026-02-25 — Added Avid Interplay Migration template support*
