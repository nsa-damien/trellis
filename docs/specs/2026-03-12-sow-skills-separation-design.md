# SOW Skills Separation Design

Split the monolithic `migration-sow-generator` skill into separate, self-contained skills — one per SOW type. Each skill is platform-agnostic (works as a Claude Code skill or a Gemini Gem) and follows a shared workflow pattern.

## Skills

| Skill Directory | Command | Template Doc ID | Status |
|-----------------|---------|-----------------|--------|
| `migration-sow-generator` | `/sow-migration` | MAM: `1QUNVJNaSUU5MztXAQHbjWTINKCJREkT8D1Kypf6WmAA`, Avid: `1wz7hGKQ_kOfKOrKxwk6AhzNNch2q4HHVOe7IxD5U3gg` | Active — cleanup only |
| `iconik-sow-generator` | `/sow-iconik` | `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg` | Build now |
| `catdv-sow-generator` | `/sow-catdv` | `13I-g12freK_Z2OjVC181Jt4rKdkHL3YP3b_-E9JXo18` | Placeholder |
| `catdv-upgrade-sow-generator` | `/sow-catdv-upgrade` | TBD | Placeholder |
| `dhub-ott-sow-generator` | `/sow-dhub` | TBD | Placeholder |

## Design Principles

1. **Self-contained** — Each skill duplicates the shared workflow pattern. No cross-file references. This makes each skill independently pasteable into a Gemini Gem.
2. **Platform-agnostic** — Operations described abstractly ("Copy the template", "Replace `#client`", "Remove content between `<TAG>` markers"). No tool-specific call syntax (no `mcp__*`, no `gws` CLI commands). The executing LLM uses whatever Google Workspace tools are available on its platform.
3. **Context-aware interview** — Users may provide notes, a BOM, or pasted data alongside the command. The skill parses available context first and switches to verify mode rather than asking every question from scratch.
4. **One question at a time** — When asking questions (fresh or verification), present one topic per message.

## Shared Workflow Pattern

Every SOW skill follows these steps:

### Step 0: Context Intake

Check if the user provided text alongside the command (notes, BOM, email, etc.).

- **If context provided:** Parse the text and extract answers to as many interview questions as possible. Present a pre-filled summary for verification. Only ask follow-up questions for missing or ambiguous values.
- **If no context:** Proceed to standard interview.

### Step 1: Interview

Ask one topic at a time. Category questions may use multi-select where appropriate (e.g., "Which deploy add-ons?").

If the answer to any question is "I don't know" or equivalent, leave the placeholder as-is in the document. Track unfilled placeholders for reporting at delivery.

### Step 2: Confirm

Present a summary table of all collected values and selections. Wait for explicit confirmation before generating.

### Step 3: Generate

1. Copy the template document to the destination folder
2. Replace all `#variable` placeholders with collected values
3. Apply conditional logic (tag processing, section removal)
4. Verify replacement counts — flag any 0-match replacements

### Step 4: Deliver

Present the document link and list manual steps remaining (logo insertion, review, send to reseller). Report any unfilled placeholders.

### Step 5: Next Steps

Offer: export PDF, share the doc, or generate another SOW.

### Error Handling

- **Copy fails:** Template doc ID may have changed. Read the template doc to verify.
- **Replacement returns 0:** Placeholder text may have changed in the template. Search for similar text.
- **Folder not found:** Fall back to default folder `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`.
- **Permission error:** Check Google Workspace authentication.

### Known Limitations

- `#logo` replacement is text-only. Actual logo insertion requires manual editing.
- Multi-line find-and-replace is unreliable in Google Docs. Prefer short, unique anchor strings.
- Document formatting/styles from the template are preserved by copy, but API-inserted text comes in as plain text.
- Removing lines by replacing with a single space leaves a blank line (Google Docs API rejects empty-string replacement).

---

## 1. migration-sow-generator Cleanup

**Changes:**
- Rename slash command: `/sow` → `/sow-migration`
- Remove Iconik and CatDV rows from the Templates table
- Remove the fallback logic: "If they ask for Iconik or CatDV Up and Running, tell them those templates haven't been integrated..."
- Add Context Intake step (Step 0) to the process
- No other changes — the existing interview, placeholder, and conditional logic stays as-is

---

## 2. iconik-sow-generator (Full Build)

### Template

- **Doc ID:** `1llE-VLSF_ivYrCSXdMvuoXECcCbd8TkSJzWWURzerOg`
- **Doc name:** TEMPLATE #client Iconik Up and Running Services SOW
- **Default Drive folder:** `10l3uRO7-VCZ7ML6YvUmp3eooqBDyWhaQ`

### Global Variables (always collected)

| Variable | Description | Example |
|----------|-------------|---------|
| `#client` | Client company name | Acme Broadcasting |
| `#reseller` | Reseller/partner company name | Signiant Media |
| `#date` | SOW date | March 12, 2026 |
| `#logo` | Company logo placeholder | *(manual — not automated)* |
| `#user_count` | Number of initial users | 25 |
| `#group_count` | Number of initial groups | 8 |
| `#acl_count` | Number of ACL templates | 5 |

### Option-Specific Variables (collected only when the option is selected)

| Variable | Collected When | Description | Example |
|----------|----------------|-------------|---------|
| `#awe_term` | AWE selected | AWE support term | 1-year |
| `#hour` | SUPPORT selected | Support hour block size | 40 |
| `#additional_training_users` | ADDL_TRAINING selected | Additional training user count | 10 |

### Options (from Template Options Index)

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

**Implicit entries (not in table but present in template):**
- **SUPPORT_DECLINED** — Mutually exclusive alternative to SUPPORT. Tag: `<SUPPORT_DECLINED>`. No variables.
- **CUSTOM_WF_CHECKLIST** — Parent tag in Exhibit 1 that mirrors CUSTOM_WORKFLOWS. Remove when all workflow child options are excluded.

### Dependency & Exclusion Rules

- CAMERA_INGEST requires VANTAGE — if user selects Camera Ingest but not Vantage, flag the dependency and ask.
- GAMEDAY requires AWE — only offer Gameday if AWE is selected.
- SUPPORT and SUPPORT_DECLINED are mutually exclusive — selecting one excludes the other. One must always be selected.

### Interview Flow

**Question order (when no context provided):**

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
11. **Date** — "What date for the SOW? Default: today"
12. **Destination folder** — Use default unless told otherwise.

### Confirmation Summary

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

### Tag Processing Rules

After copying the template and replacing all `#variable` placeholders:

1. **Selected option:** Remove the `<TAG>` and `</TAG>` markers. Keep all content between them.
2. **Excluded option:** Remove the `<TAG>` marker, the `</TAG>` marker, and all content between them.
3. **Parent tag rollup:** If all children of a parent tag are excluded, apply rule 2 to the parent tag:
   - DEPLOY_OPTIONS — if none of CLOUD_ARCHIVE, SSO, EDIT_PROXY, VANTAGE selected
   - CUSTOM_WORKFLOWS — if none of ARCHIVE_WF, REVIEW_WF, REMOTE_EDIT, CAMERA_INGEST, GAMEDAY selected
   - CUSTOM_WF_CHECKLIST — mirrors CUSTOM_WORKFLOWS (same rollup logic, applied in Exhibit 1)
4. **GAMEDAY dual-parent:** GAMEDAY content appears in both `<AWE>` and `<CUSTOM_WORKFLOWS>`. Remove or keep consistently in both locations.
5. **SUPPORT/SUPPORT_DECLINED mutual exclusion:** The selected one keeps its content (tags stripped). The excluded one has tags and content removed.
6. **Processing order:** Process child tags before parent tags (bottom-up). This ensures parent rollup detection works correctly.

### Also Remove

After tag processing, also remove the **SOW Options Index** section and the **Global Variables** table from the top of the generated document. These are reference material for the generator, not client-facing content.

### Delivery

```
SOW GENERATED:
  Document: {client} Iconik Up and Running SOW - {date}
  Link:     {google_doc_link}

Manual steps remaining:
  1. Replace "#logo" text with actual client/project logo
  2. Review document for accuracy
  3. Send to reseller for pricing and PO
```

If any placeholders were left unfilled, list them.

---

## 3. catdv-sow-generator (Placeholder)

- **Slash command:** `/sow-catdv`
- **Template Doc ID:** `13I-g12freK_Z2OjVC181Jt4rKdkHL3YP3b_-E9JXo18`
- **Content:** Frontmatter + template ID + "This SOW template is not yet integrated into the automated workflow."

---

## 4. catdv-upgrade-sow-generator (Placeholder)

- **Slash command:** `/sow-catdv-upgrade`
- **Template Doc ID:** TBD
- **Content:** Frontmatter + "This SOW template is not yet integrated. No template document exists yet."

---

## 5. dhub-ott-sow-generator (Placeholder)

- **Slash command:** `/sow-dhub`
- **Template Doc ID:** TBD
- **Content:** Frontmatter + "This SOW template is not yet integrated. No template document exists yet."

---

*Spec created: 2026-03-12*
