---
name: context-handoff
description: Generate a context handoff document for seamless session continuity. Use when a Claude Code session is approaching context limits, when the user wants to pause work and resume later, when switching between sessions on the same task, or when the user says "handoff", "context handoff", or "save context". Produces a handoff.md file that enables a new session to resume work without re-explanation.
---

# Context Handoff

Generate a `handoff.md` file that captures everything a fresh Claude Code session needs to resume the current work seamlessly.

## Process

### 1. Gather objective state

Run these commands and capture their output for analysis:

```bash
# Branch and commit state
git branch --show-current
git log --oneline -10
git status --short

# What changed this session (staged + unstaged + untracked)
git diff --stat HEAD~5 2>/dev/null || git diff --stat

# Any stashed work
git stash list
```

Also note:
- Current working directory
- Any running background processes or servers relevant to the work
- Active beads issues if `bd` is available (`bd list --status=in_progress`)

### 2. Synthesize from conversation memory

Reflect on the full conversation and extract:

- **The goal**: What the user asked for, in their words and in technical terms
- **What's done**: Completed work with enough detail to not re-do it
- **What's in progress**: Partially completed work and its current state
- **What's left**: Remaining work, ordered by priority
- **Decisions made**: Choices and their rationale — these are expensive to re-derive
- **Dead ends**: Approaches that were tried and abandoned, and why — prevents repeating mistakes
- **Key discoveries**: Non-obvious things learned during the session (quirks, undocumented behavior, surprising constraints)
- **Active mental model**: How the relevant code/system actually works, as understood through this session's work

### 3. Write handoff.md

Write to `handoff.md` in the project root using this structure:

```markdown
# Context Handoff
<!-- Generated: {timestamp} | Branch: {branch} | Session: {brief-description} -->

## Goal
{What we're trying to accomplish. Start with the user's original request, then add
technical framing. A new session should read this and immediately understand the mission.}

## Status

### Completed
- {Thing done} — {file(s) touched}
- ...

### In Progress
- {Partially done thing} — {current state, what's left on it}

### Remaining
- [ ] {Next task, in priority order}
- [ ] ...

## Key Files
| File | Role | State |
|------|------|-------|
| {path} | {what it does in this context} | {modified/created/needs-work} |

## Decisions
| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| {chose X} | {why} | {Y, Z — why not} |

## Dead Ends
- **{Approach}**: {Why it failed or was abandoned. Be specific enough to prevent retry.}

## Discoveries
- {Non-obvious finding that would take time to rediscover}

## Git State
- **Branch**: {branch name}
- **Last commit**: {hash} {message}
- **Uncommitted changes**: {summary or "none"}
- **Beads**: {active issue IDs and titles, or "n/a"}

## Resume Instructions
{Concrete first steps for the next session. Not "continue working" — specific actions
like "Run the test suite to verify X still passes, then implement the Y function in Z file."}
```

### 4. Confirm with user

After writing, display:
- The file path
- A 2-3 line summary of what was captured
- Reminder: "Start your next session with: read handoff.md"

## Guidelines

- **Bias toward too much context over too little.** A fresh session has zero memory. Anything omitted must be rediscovered from scratch.
- **Be concrete, not abstract.** "Modified the search query builder" is useless. "Added fuzzy matching to `buildQuery()` in `search.service.ts:142` using Levenshtein distance with threshold 2" is actionable.
- **Capture the _why_ behind decisions.** Code shows _what_ was done. The handoff must preserve _why_ — the reasoning that led to the current approach.
- **Include failed approaches.** A new session will naturally consider the same approaches. Documenting dead ends saves significant re-exploration time.
- **Git state is not enough.** `git diff` shows what changed but not what it means, what's left, or what was learned. The handoff bridges that gap.
- **Omit sections that don't apply.** If there are no dead ends or discoveries, drop those sections rather than writing "None."
