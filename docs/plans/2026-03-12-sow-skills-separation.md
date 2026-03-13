# SOW Skills Separation Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the monolithic SOW generator into 5 separate skills — clean up migration, build iconik fully, create 3 placeholders.

**Architecture:** Each skill is a self-contained SKILL.md file in its own directory under `skills/`. New skills use platform-agnostic operation descriptions (no MCP tool syntax). The existing migration skill keeps its MCP calls.

**Tech Stack:** Markdown (Claude Code skill format), Google Docs API (via platform tools)

**Spec:** `docs/specs/2026-03-12-sow-skills-separation-design.md`

---

## Chunk 1: Migration Cleanup + Placeholder Skills

### Task 1: Clean up migration-sow-generator

**Files:**
- Modify: `skills/migration-sow-generator/SKILL.md`

- [ ] **Step 1: Update frontmatter — rename slash command**

In `skills/migration-sow-generator/SKILL.md`, change the frontmatter:

```yaml
---
name: migration-sow-generator
description: |
  Generate Migration SOWs (MAM Migration and Avid Interplay Migration) from templates.
  Interviews for project details, copies the template, replaces placeholders, applies
  conditional logic, and delivers a ready-to-review Google Doc.
license: MIT
compatibility: marvin
metadata:
  marvin-category: work
  user-invocable: true
  slash-command: /sow-migration
  model: default
  proactive: false
---
```

Only change: `slash-command: /sow` → `slash-command: /sow-migration`

- [ ] **Step 2: Remove Iconik and CatDV rows from Templates table**

Replace the Templates table with:

```markdown
## Templates

| Template | Google Doc ID | Status |
|----------|---------------|--------|
| MAM Migration | `1QUNVJNaSUU5MztXAQHbjWTINKCJREkT8D1Kypf6WmAA` | Active |
| Avid Interplay Migration | `1wz7hGKQ_kOfKOrKxwk6AhzNNch2q4HHVOe7IxD5U3gg` | Active |

See also: `/sow-iconik`, `/sow-catdv`, `/sow-catdv-upgrade`, `/sow-dhub`
```

- [ ] **Step 3: Remove Iconik/CatDV fallback logic**

In Step 1 (Select Template), remove these two lines:

```
If they ask for Iconik or CatDV Up and Running, tell them those templates
haven't been integrated into the workflow yet and offer to generate manually.
```

- [ ] **Step 4: Add Context Intake step**

Insert before "### Step 1: Select Template":

```markdown
### Step 0: Context Intake

Check if the user provided text alongside the command (notes, BOM, email, etc.).

- **If context provided:** Parse the text to extract client name, reseller, source platform, and (for Avid) infrastructure details (data size, hypervisor, network, etc.). If context mentions "Avid", "Interplay", "OP-1a", or "MXF", auto-select the Avid template. Present extracted values for verification, then proceed to the standard interview for any gaps.
- **If no context:** Proceed to Step 1.
```

- [ ] **Step 5: Update footer**

Change the footer to:

```markdown
*Skill created: 2026-02-25*
*Updated: 2026-03-12 — Renamed to /sow-migration, added Context Intake, removed non-migration templates*
```

- [ ] **Step 6: Verify and commit**

```bash
# Verify the file looks correct
head -20 skills/migration-sow-generator/SKILL.md
# Commit
git add skills/migration-sow-generator/SKILL.md
git commit -m "refactor(sow): rename /sow to /sow-migration, clean up non-migration references"
```

---

### Task 2: Create catdv-sow-generator placeholder

**Files:**
- Create: `skills/catdv-sow-generator/SKILL.md`

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/catdv-sow-generator
```

Write `skills/catdv-sow-generator/SKILL.md`:

```markdown
---
name: catdv-sow-generator
description: |
  Generate CatDV Up and Running SOWs from template. Interviews for project details,
  copies the template, replaces placeholders, applies conditional logic, and delivers
  a ready-to-review Google Doc.
license: MIT
compatibility: marvin
metadata:
  marvin-category: work
  user-invocable: true
  slash-command: /sow-catdv
  model: default
  proactive: false
---

# CatDV Up and Running SOW Generator

Generate CatDV Up and Running Statements of Work from NSA templates via Google Docs.

## Template

- **Doc ID:** `13I-g12freK_Z2OjVC181Jt4rKdkHL3YP3b_-E9JXo18`
- **Default Drive folder:** `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`

## Status

This SOW template is not yet integrated into the automated workflow. The template document exists but the interview flow, placeholder reference, and conditional logic have not been defined.

To generate a CatDV Up and Running SOW manually:
1. Copy the template document from the ID above
2. Review the template for placeholder variables and optional sections
3. Fill in values manually in the copied document

See also: `/sow-migration`, `/sow-iconik`, `/sow-catdv-upgrade`, `/sow-dhub`

---

*Skill created: 2026-03-12*
```

- [ ] **Step 2: Commit**

```bash
git add skills/catdv-sow-generator/SKILL.md
git commit -m "feat(sow): add catdv-sow-generator placeholder skill"
```

---

### Task 3: Create catdv-upgrade-sow-generator placeholder

**Files:**
- Create: `skills/catdv-upgrade-sow-generator/SKILL.md`

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/catdv-upgrade-sow-generator
```

Write `skills/catdv-upgrade-sow-generator/SKILL.md`:

```markdown
---
name: catdv-upgrade-sow-generator
description: |
  Generate CatDV Upgrade and/or Cloud Migration SOWs from template. Covers version
  upgrades and on-prem to cloud migration scenarios.
license: MIT
compatibility: marvin
metadata:
  marvin-category: work
  user-invocable: true
  slash-command: /sow-catdv-upgrade
  model: default
  proactive: false
---

# CatDV Upgrade & Cloud Migration SOW Generator

Generate CatDV Upgrade and/or Cloud Migration Statements of Work from NSA templates via Google Docs.

## Template

- **Doc ID:** TBD — no template document exists yet
- **Default Drive folder:** `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`

## Status

This SOW template is not yet integrated. No template document exists yet.

This skill will cover:
- CatDV version upgrades
- On-premises to cloud migration
- Combined upgrade + migration scenarios

See also: `/sow-migration`, `/sow-iconik`, `/sow-catdv`, `/sow-dhub`

---

*Skill created: 2026-03-12*
```

- [ ] **Step 2: Commit**

```bash
git add skills/catdv-upgrade-sow-generator/SKILL.md
git commit -m "feat(sow): add catdv-upgrade-sow-generator placeholder skill"
```

---

### Task 4: Create dhub-ott-sow-generator placeholder

**Files:**
- Create: `skills/dhub-ott-sow-generator/SKILL.md`

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/dhub-ott-sow-generator
```

Write `skills/dhub-ott-sow-generator/SKILL.md`:

```markdown
---
name: dhub-ott-sow-generator
description: |
  Generate Dhub OTT SOWs from template. Covers net-new Dhub OTT product deployments.
license: MIT
compatibility: marvin
metadata:
  marvin-category: work
  user-invocable: true
  slash-command: /sow-dhub
  model: default
  proactive: false
---

# Dhub OTT SOW Generator

Generate Dhub OTT Statements of Work from NSA templates via Google Docs.

## Template

- **Doc ID:** TBD — no template document exists yet
- **Default Drive folder:** `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`

## Status

This SOW template is not yet integrated. No template document exists yet.

This skill will cover:
- Net-new Dhub OTT product deployments

See also: `/sow-migration`, `/sow-iconik`, `/sow-catdv`, `/sow-catdv-upgrade`

---

*Skill created: 2026-03-12*
```

- [ ] **Step 2: Commit**

```bash
git add skills/dhub-ott-sow-generator/SKILL.md
git commit -m "feat(sow): add dhub-ott-sow-generator placeholder skill"
```

---

## Chunk 2: Iconik SOW Generator (Full Build)

### Task 5: Create iconik-sow-generator SKILL.md

**Files:**
- Create: `skills/iconik-sow-generator/SKILL.md`

- [ ] **Step 1: Create directory**

```bash
mkdir -p skills/iconik-sow-generator
```

- [ ] **Step 2: Write the full SKILL.md**

Write `skills/iconik-sow-generator/SKILL.md` with the complete content below:

```markdown
---
name: iconik-sow-generator
description: |
  Generate Iconik Up and Running SOWs from template. Interviews for project details,
  copies the template, replaces placeholders, applies tag-based conditional logic
  (deploy options, workflows, support), and delivers a ready-to-review Google Doc.
license: MIT
compatibility: marvin
metadata:
  marvin-category: work
  user-invocable: true
  slash-command: /sow-iconik
  model: default
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

## Global Variables (always collected)

| Variable | Description | Example |
|----------|-------------|---------|
| `#client` | Client company name | Acme Broadcasting |
| `#reseller` | Reseller/partner company name | Signiant Media |
| `#date` | SOW date | March 12, 2026 |
| `#logo` | Company logo placeholder | *(manual — not automated)* |
| `#user_count` | Number of initial users | 25 |
| `#group_count` | Number of initial groups | 8 |
| `#acl_count` | Number of ACL templates | 5 |

## Option-Specific Variables (collected only when the option is selected)

| Variable | Collected When | Description | Example |
|----------|----------------|-------------|---------|
| `#awe_term` | AWE selected | AWE support term | 1-year |
| `#hour` | SUPPORT selected | Support hour block size | 40 |
| `#additional_training_users` | ADDL_TRAINING selected | Additional training user count | 10 |

## Options (from Template Options Index)

| Code | Category | Description | Parent Tag | Requires | Variables |
|------|----------|-------------|------------|----------|-----------|
| CLOUD_ARCHIVE | Deploy | Third-party cloud archive storage | DEPLOY_OPTIONS | — | — |
| SSO | Deploy | External authentication (SSO/SAML) | DEPLOY_OPTIONS | — | — |
| EDIT_PROXY | Deploy | ISG-based edit proxy (mezzanine) | DEPLOY_OPTIONS | — | — |
| VANTAGE | Deploy | Telestream Vantage transcoder (up to 2) | DEPLOY_OPTIONS | — | — |
| AWE | Deploy | AWE workflow engine & Iconik connector | AWE | — | awe_term |
| ARCHIVE_WF | Workflow | Archive workflow consulting/design | CUSTOM_WORKFLOWS | — | — |
| REVIEW_WF | Workflow | Review & approval workflow | CUSTOM_WORKFLOWS | — | — |
| REMOTE_EDIT | Workflow | Remote editorial with VFS | CUSTOM_WORKFLOWS | — | — |
| CAMERA_INGEST | Workflow | Camera ingest / Telestream | CUSTOM_WORKFLOWS | VANTAGE | — |
| GAMEDAY | Workflow | Gameday bundle (Ingest+DLR+EVS) | AWE + CUSTOM_WORKFLOWS | AWE | — |
| ADDL_TRAINING | Training | Additional training users/sessions | — | — | additional_training_users |
| SUPPORT | Support | NSA support hour block | SUPPORT | — | hour |

**Implicit entries (not in Options Index table but present in template):**
- **SUPPORT_DECLINED** — Mutually exclusive alternative to SUPPORT. Tag: `<SUPPORT_DECLINED>`. No variables.
- **CUSTOM_WF_CHECKLIST** — Parent tag in Exhibit 1 that mirrors CUSTOM_WORKFLOWS. Contains individually tagged children (`<ARCHIVE_WF>`, `<REVIEW_WF>`, `<REMOTE_EDIT>`, `<CAMERA_INGEST>`, `<GAMEDAY>`). Remove entire section when all workflow child options are excluded.

## Dependency & Exclusion Rules

- CAMERA_INGEST requires VANTAGE — if user selects Camera Ingest but not Vantage, flag the dependency and ask.
- GAMEDAY requires AWE — only offer Gameday if AWE is selected.
- SUPPORT and SUPPORT_DECLINED are mutually exclusive — selecting one excludes the other. One must always be selected.

## Process

### Step 0: Context Intake

Check if the user provided text alongside the command (notes, BOM, email, etc.).

- **If context provided:** Parse the text and extract answers to as many interview questions as possible — client name, reseller, user/group/ACL counts, which options are included, support hours, AWE term, etc. Present a pre-filled summary for verification. Only ask follow-up questions for missing or ambiguous values.
- **If no context:** Proceed to Step 1.

### Step 1: Interview

Ask **one question at a time**.

If the answer to any question is "I don't know" or equivalent, leave the placeholder as-is in the document. Track unfilled placeholders for reporting at delivery.

**Question order:**

1. **Client name** — "What's the client name?"
2. **Reseller** — "Who's the reseller?"
3. **Initial users** — "How many initial users?"
4. **Initial groups** — "How many initial groups?"
5. **ACL templates** — "How many ACL templates?"
6. **Deploy add-ons** — "Which deployment add-ons? (Cloud Archive, SSO, Edit Proxy, Vantage — select all that apply, or none)"
7. **AWE** — "Include AWE (Akomi Workflow Engine)?" → if yes: "What AWE support term?" (`#awe_term`) → then: "Include Gameday bundle (Ingest+DLR+EVS)?"
8. **Custom workflows** — "Which custom workflows? (Archive WF, Review & Approval, Remote Edit, Camera Ingest — select all that apply, or none)" — enforce Camera Ingest requires Vantage
9. **Additional training** — "Additional training beyond the base 5 power users?" → if yes: "How many additional users?" (`#additional_training_users`)
10. **Support** — "Include NSA support hour block, or declined?" → if support: "How many hours?" (`#hour`)
11. **Date** — "What date for the SOW? Default: today" *(Format as full month, e.g., "March 12, 2026")*
12. **Destination folder** — Use default unless told otherwise.

### Step 2: Confirm

Present a summary table before creating anything:

```
SOW DETAILS:
  Template:    Iconik Up and Running
  Client:      {client}
  Reseller:    {reseller}
  Users:       {user_count}
  Groups:      {group_count}
  ACLs:        {acl_count}

  Deploy Add-ons:     {list or "None"}
  AWE:                Yes/No  (term: {awe_term})
  Gameday:            Yes/No
  Custom Workflows:   {list or "None"}
  Addl Training:      {additional_training_users} users / No
  Support:            {hour} hours / Declined

  Date:        {date}
  Save to:     {folder name}
  Doc name:    {client} Iconik Up and Running SOW - {date}

Ready to generate?
```

Wait for explicit confirmation before proceeding.

### Step 3: Create the Document

#### 3a. Find destination folder (if not using default)

Search Google Drive for the folder name. If multiple matches, ask which one. If no match, use default folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`.

#### 3b. Copy template

Copy the template document `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg` to the destination folder with name: `{client} Iconik Up and Running SOW - {date}`

#### 3c. Replace global variables

Replace all `#variable` placeholders with collected values. Use case-sensitive matching. Run in parallel where possible, batching in groups of 6-8 to avoid API timeouts.

| Find | Replace With |
|------|-------------|
| `#client` | {client} |
| `#reseller` | {reseller} |
| `#date` | {date} |
| `#logo` | {client} *(temporary — note for manual logo insertion)* |
| `#user_count` | {user_count} |
| `#group_count` | {group_count} |
| `#acl_count` | {acl_count} |

#### 3d. Replace option-specific variables

Only for selected options. Skip any marked "don't know."

| Find | Replace With | Condition |
|------|-------------|-----------|
| `#awe_term` | {awe_term} | AWE selected |
| `#hour` | {hour} | SUPPORT selected |
| `#additional_training_users` | {additional_training_users} | ADDL_TRAINING selected |

**IMPORTANT:** After replacements, verify counts in the responses. If any replacement returns 0 matches, flag it — the template may have changed.

#### 3e. Process conditional tags

Process child tags before parent tags (bottom-up). Use find-and-replace to replace tag markers with a single space (Google Docs API rejects empty-string replacements).

**For each SELECTED option:** Remove the `<TAG>` and `</TAG>` markers only. Keep all content between them.

**For each EXCLUDED option:** Remove the `<TAG>` marker, the `</TAG>` marker, and all content between them.
- For inline tags (e.g., `<AWE>AWE Deployment</AWE>` on a single line), find-and-replace the entire string with a single space.
- For block tags spanning multiple lines, use index-based deletion if the platform supports it, or iterative find-and-replace on identifiable anchor lines within the block.

**Processing order (bottom-up):**

1. **GAMEDAY** — Two separate `<GAMEDAY>...</GAMEDAY>` blocks exist: one nested inside `<AWE>` (deployment items) and one nested inside `<CUSTOM_WORKFLOWS>` (workflow descriptions). Process both identically.
2. **CLOUD_ARCHIVE, SSO, EDIT_PROXY, VANTAGE** — Inside `<DEPLOY_OPTIONS>`
3. **ARCHIVE_WF, REVIEW_WF, REMOTE_EDIT, CAMERA_INGEST** — Inside `<CUSTOM_WORKFLOWS>` and `<CUSTOM_WF_CHECKLIST>`
4. **ADDL_TRAINING** — Standalone
5. **SUPPORT / SUPPORT_DECLINED** — Mutually exclusive. Keep the selected one (strip tags), remove the excluded one (strip tags + content).
6. **AWE** — Top-level parent. Process after GAMEDAY.
7. **DEPLOY_OPTIONS** — Parent rollup: remove entire section if none of CLOUD_ARCHIVE, SSO, EDIT_PROXY, VANTAGE selected.
8. **CUSTOM_WORKFLOWS** — Parent rollup: remove entire section if none of ARCHIVE_WF, REVIEW_WF, REMOTE_EDIT, CAMERA_INGEST, GAMEDAY selected.
9. **CUSTOM_WF_CHECKLIST** — Exhibit 1 mirror of CUSTOM_WORKFLOWS. Same rollup logic.

#### 3f. Remove generator reference material

Remove the following from the top of the generated document (not client-facing):
- The heading **"SOW Options Index"** and all content through the end of the Options Index table
- The introductory paragraph starting with "This table defines all optional sections..."
- The heading **"Global Variables (always collected)"** and all content through the end of the Global Variables table

### Step 4: Deliver

Present the result:

```
SOW GENERATED:
  Document: {client} Iconik Up and Running SOW - {date}
  Link:     {google_doc_link}

Manual steps remaining:
  1. Replace "#logo" text with actual client/project logo
  2. Review document for accuracy
  3. Send to reseller for pricing and PO
```

If any placeholders were left unfilled:
```
  Unfilled placeholders (need manual entry):
    - #awe_term (AWE Support Term)
    - ...
```

### Step 5: Offer Next Steps

After delivery, ask:
> "Want me to export a PDF, share the doc with someone, or generate another SOW?"

## Error Handling

- **Copy fails:** Template doc ID may have changed. Read the template doc to verify.
- **Replacement returns 0:** Placeholder text may have changed in the template. Search for similar text.
- **Folder not found:** Fall back to default folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`.
- **Permission error:** Check Google Workspace authentication.
- **API timeout:** When performing many find-and-replace operations, batch in groups of 6-8. Retry failures individually.

## Known Limitations

- `#logo` replacement is text-only. Actual logo insertion requires manual editing in Google Docs.
- Multi-line find-and-replace is unreliable in Google Docs. Prefer short, unique anchor strings.
- Document formatting/styles from the template are preserved by copy, but API-inserted text comes in as plain text.
- Removing lines by replacing with a single space leaves a blank line (Google Docs API rejects empty-string replacement).

---

*Skill created: 2026-03-12*
```

- [ ] **Step 3: Verify the file renders correctly**

```bash
head -30 skills/iconik-sow-generator/SKILL.md
wc -l skills/iconik-sow-generator/SKILL.md
```

Expected: ~250-280 lines, frontmatter parses correctly.

- [ ] **Step 4: Commit**

```bash
git add skills/iconik-sow-generator/SKILL.md
git commit -m "feat(sow): add iconik-sow-generator skill with full interview and tag processing"
```

---

## Chunk 3: Project Updates

### Task 6: Update CLAUDE.md skill table

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add new skills to the Supporting skills table**

In the `### Supporting` table in CLAUDE.md, add rows for the new SOW skills. Find the existing `/trellis:migration-sow-generator` reference pattern and add alongside it. The skills section should include:

| Skill | Purpose |
|-------|---------|
| `/trellis:migration-sow-generator` | **Migration SOWs** — MAM and Avid Interplay migration (`/sow-migration`) |
| `/trellis:iconik-sow-generator` | **Iconik Up and Running SOW** — full interview + tag processing (`/sow-iconik`) |
| `/trellis:catdv-sow-generator` | **CatDV Up and Running SOW** — placeholder (`/sow-catdv`) |
| `/trellis:catdv-upgrade-sow-generator` | **CatDV Upgrade/Cloud Migration SOW** — placeholder (`/sow-catdv-upgrade`) |
| `/trellis:dhub-ott-sow-generator` | **Dhub OTT SOW** — placeholder (`/sow-dhub`) |

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add new SOW skill commands to CLAUDE.md"
```

---

### Task 7: Update CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add unreleased section**

Add to the `[Unreleased]` section (or create one if it doesn't exist):

```markdown
### Added
- `iconik-sow-generator` skill (`/sow-iconik`) — full interview flow with tag-based conditional logic for Iconik Up and Running SOWs
- `catdv-sow-generator` skill (`/sow-catdv`) — placeholder for CatDV Up and Running SOWs
- `catdv-upgrade-sow-generator` skill (`/sow-catdv-upgrade`) — placeholder for CatDV Upgrade & Cloud Migration SOWs
- `dhub-ott-sow-generator` skill (`/sow-dhub`) — placeholder for Dhub OTT SOWs

### Changed
- Renamed `migration-sow-generator` slash command from `/sow` to `/sow-migration`
- Removed Iconik and CatDV references from migration-sow-generator (now separate skills)
- Added Context Intake (Step 0) to migration-sow-generator for pre-filled interviews
```

- [ ] **Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for SOW skills separation"
```

---

## Execution Notes

**Parallelism:** Tasks 2, 3, 4 (placeholder skills) can run in parallel. Task 5 (iconik) is independent. Task 1 (migration cleanup) is independent. Tasks 6-7 should run after 1-5 are complete.

**Verification:** After all tasks complete, verify the skill list recognizes the new commands by checking that each SKILL.md has valid frontmatter with the correct `slash-command`.
