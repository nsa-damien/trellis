---
name: ideas
description: |
  Capture, track, and prioritize project ideas — enhancements, features, refinements,
  and general brainstorms. Maintains docs/IDEAS.md as a living backlog of possibilities.
  Use when the user says "idea", "I was thinking we could", "wouldn't it be cool if",
  "enhancement", "feature idea", "we should eventually", "add to the backlog",
  or invokes /trellis:ideas. Also use when the user wants to review, prioritize,
  or promote ideas to actionable work.
license: MIT
metadata:
  user-invocable: true
  slash-command: /trellis:ideas
  proactive: false
---

# Ideas Tracker

Capture and manage project ideas in `docs/IDEAS.md`. Every invocation starts by reading the current file to build context and prevent duplicates.

## On Every Invocation

1. Read `docs/IDEAS.md` (create it if it doesn't exist — see File Format below)
2. Parse all existing ideas into memory
3. Determine the operation from the user's input:
   - **No args or "list"** → List operation
   - **"add" or a description of an idea** → Add operation
   - **"review"** → Review operation
   - **"promote"** → Promote operation
   - **Idea text provided inline** (e.g., `/trellis:ideas we should add dark mode support`) → Add operation, skip the prompt and go straight to categorization

## Operations

### Add

Capture a new idea. If the user provided the idea inline, skip step 1.

1. Ask: "What's the idea?"
2. Check for duplicates — scan existing ideas for similar titles or descriptions. If a likely duplicate exists, show it and ask: "This looks similar to an existing idea: **{title}**. Is this the same thing, or a distinct idea?"
3. Ask: "What category — enhancement, feature, refinement, or general idea?"
4. Ask: "What's the expected impact — high, medium, or low?" Offer brief guidance:
   - **High** — meaningfully changes how users work, unlocks new capability, or removes significant friction
   - **Medium** — clear improvement, nice to have, moderate reach
   - **Low** — minor polish, edge case, or affects few users
5. **Estimate effort yourself** — do not ask the user. Assess the effort based on your understanding of the project's codebase, architecture, and the scope of the idea:
   - **Small** — an hour or less, straightforward change (e.g., config tweak, copy change, adding a field)
   - **Medium** — a focused session, some complexity (e.g., new skill, refactoring a workflow, adding a feature with a few moving parts)
   - **Large** — multiple sessions, significant design or implementation work (e.g., new architecture, cross-cutting changes, external integrations)
   State your estimate and a one-sentence rationale when presenting the confirmation. The user can override if they disagree.
6. Write the new idea to `docs/IDEAS.md` under the appropriate section
7. Confirm: "Added: **{title}** ({category}, {impact} impact, {effort} effort — *{rationale}*)"

### List

Show a summary of all ideas, grouped by status.

```
IDEAS SUMMARY ({total} ideas)

Active ({count}):
  #{id} {title} — {category}, {impact} impact, {effort} effort

Promoted ({count}):
  #{id} {title} → {beads_id or "promoted"}

Dropped ({count}):
  #{id} {title} — {reason}
```

If there are more than 10 active ideas, also show a priority matrix:

```
PRIORITY MATRIX (impact × effort):

  High Impact + Small Effort (quick wins):
    #{id} {title}

  High Impact + Large Effort (strategic):
    #{id} {title}

  Low Impact + Small Effort (fill work):
    #{id} {title}

  Low Impact + Large Effort (reconsider):
    #{id} {title}
```

### Review

Interactive prioritization session. Walk through active ideas and help the user reassess.

1. Present active ideas sorted by current priority (high impact + small effort first)
2. For each idea, show the current ratings. Re-evaluate the effort estimate yourself based on current project state — if your assessment differs from the recorded value, flag it (e.g., "Effort: medium → I'd now call this small since we added the X framework"). Then ask: "Still accurate? Change impact, promote, drop, or skip?"
3. Accept quick responses: "skip", "drop", "promote", "impact high", "effort small", etc.
4. After reviewing all ideas (or when the user says "done"), save updates and show the updated priority matrix

### Promote

Convert an idea into actionable work.

1. If no idea specified, show active ideas and ask which one
2. Check if beads is available (`which bd`)
3. **If beads available:** Create a beads issue from the idea:
   ```bash
   bd create --title="{title}" --type={feature|task} --priority={mapped_priority}
   ```
   Map impact to beads priority: high→1, medium→2, low→3
4. **If beads not available:** Mark as promoted without a beads ID
5. Update the idea's status in `docs/IDEAS.md` to `promoted` with a reference to the beads ID (if created)
6. Confirm: "Promoted #{id} **{title}** → {beads_id or 'promoted'}"

## File Format

`docs/IDEAS.md` uses this structure:

```markdown
# Project Ideas

> Captured ideas for enhancements, features, and refinements. Managed by `/trellis:ideas`.

## Active

| # | Title | Category | Impact | Effort | Added |
|---|-------|----------|--------|--------|-------|
| 1 | Example idea title | feature | high | medium | 2026-03-16 |

## Promoted

| # | Title | Promoted To | Date |
|---|-------|-------------|------|

## Dropped

| # | Title | Reason | Date |
|---|-------|--------|------|
```

**Rules:**
- IDs are auto-incrementing integers, never reused
- Dates use ISO format (YYYY-MM-DD)
- Categories: `feature`, `enhancement`, `refinement`, `idea`
- Impact: `high`, `medium`, `low`
- Effort: `small`, `medium`, `large`
- When moving an idea between sections, remove it from the source table and add it to the destination table

## Creating the File

If `docs/IDEAS.md` doesn't exist, create it with the empty template above (no example row) and inform the user: "Created docs/IDEAS.md — ready to capture ideas."

---

*Skill created: 2026-03-16*
