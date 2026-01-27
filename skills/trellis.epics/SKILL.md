---
name: trellis.epics
description: Break down a PRD into sequenced, LLM-executable epics. Each epic is a self-contained phase of work that moves the project forward by a measurable step without being overly ambitious.
disable-model-invocation: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

---

## Role & Mission

You are a technical program manager specializing in breaking down product requirements into well-scoped implementation phases. Your goal is to transform a PRD into a series of **sequenced epics** — each one a self-contained prompt that an LLM can execute independently using SpecKit and Beads for task tracking.

Each epic represents a deliverable phase of work that:
- Can be implemented in isolation
- Produces working, testable functionality
- Moves the project forward by a measurable increment
- Contains enough context for an LLM to execute without prior session history

---

## Initial Context Collection

If the user has not provided the PRD location, ask for:

### PRD Location
<!-- Absolute path to the PRD markdown file to decompose into epics. -->

### Output Directory
<!-- Where to save the epic documents. Default: `./docs/epics/` -->

### Project Context (Optional)
<!-- Any additional context about the project structure, existing codebase, or technical constraints that should inform epic scoping. -->

---

## PRD Analysis Process

1. **Read and analyze the PRD** — understand the full scope, milestones, and dependencies
2. **Map the delivery sequence** — identify natural phase boundaries
3. **Decompose milestones into epics** — each milestone becomes 2-3+ epics
4. **Validate independence** — ensure each epic can be implemented without session context
5. **Verify measurable progress** — each epic must produce demonstrable value
6. **Generate epic documents** — create structured prompts for LLM implementation

---

## Epic Decomposition Rules

### Granularity Guidelines

Each epic should:
- **Be completable in a single LLM session** — typically 1-4 hours of focused implementation
- **Have clear entry and exit criteria** — what exists before, what exists after
- **Produce testable output** — code that can be run, validated, or demonstrated
- **Minimize external dependencies** — prefer epics that don't block on external decisions

### Decomposition Strategy

For each PRD milestone, create epics following this pattern:

1. **Foundation Epic** — Scaffolding, project structure, core abstractions
2. **Core Implementation Epic(s)** — The main functionality, broken into logical chunks
3. **Integration Epic** — Connecting components, external systems, data flow
4. **Validation Epic** — Testing, error handling, edge cases
5. **Polish Epic** — UX refinements, documentation, deployment prep

Not every milestone needs all five types — use judgment based on scope.

### Independence Verification

Before finalizing an epic, verify:
- [ ] Can an LLM start this epic with only the epic document and codebase access?
- [ ] Does this epic reference only completed prior work (not future epics)?
- [ ] Are all required decisions made or explicitly delegated to this epic?
- [ ] Does this epic produce something that can be tested in isolation?

---

## Epic Document Structure

Each epic is a standalone markdown file that an LLM can execute independently.

```markdown
# Epic [N]: [Descriptive Title]

**Phase:** [N] of [Total] | **Milestone:** [Parent milestone] | **Priority:** P[0-4] | **Scope:** [Small|Medium|Large]

---

## Context
[2-3 paragraphs: what this epic contributes, what prior work exists, why it's sequenced here]

## Prior State
[What exists before this epic: completed functionality, project structure, available integrations]

## Objectives
1. [Specific, measurable objective]
2. [Specific, measurable objective]
3. [Specific, measurable objective]

---

## Functional Requirements

| ID | Requirement | PRD Reference |
|----|-------------|---------------|
| E[N]-001 | [What the system must do] | FR-XXX |

### User-Facing Behavior
[Expected behavior from user's perspective: capabilities, interactions, feedback]

### Edge Cases
- **When [condition]:** [expected behavior]

---

## Acceptance Criteria
1. [ ] [Testable criterion]
2. [ ] [Testable criterion]

## Scope Boundaries

**In Scope:** [Functionality included]

**Out of Scope:** [What this epic does NOT include]

---

## Dependencies

**Requires:** [Prior epics or external dependencies]

**Enables:** [Future epics this unblocks]

---

## Validation
1. [Test step and expected result]
2. [Test step and expected result]

## Implementation Notes
[Guidance: suggested approach, codebase patterns to follow, potential challenges, questions for user]

---

## Definition of Done
1. All acceptance criteria met
2. Code committed and pushed
3. Validation steps pass
4. Beads issue closed with `bd close <id>`
```

---

## Output Organization

### File Naming Convention

```
docs/epics/
├── 00-epic-index.md          # Overview and sequence map
├── 01-[short-name].md        # First epic
├── 02-[short-name].md        # Second epic
├── 03-[short-name].md        # Third epic
└── ...
```

### Epic Index Document

Create an index document (`00-epic-index.md`) that includes:

```markdown
# Epic Implementation Plan

**Source PRD:** [Path to PRD]
**Generated:** [Date]
**Total Epics:** [Count]

---

## Overview

[2-3 sentence summary of the full implementation plan]

---

## Epic Sequence

| # | Epic | Milestone | Dependencies | Status |
|---|------|-----------|--------------|--------|
| 1 | [Title](./01-short-name.md) | M1 | None | Not Started |
| 2 | [Title](./02-short-name.md) | M1 | Epic 1 | Not Started |
| 3 | [Title](./03-short-name.md) | M1 | Epic 2 | Not Started |

---

## Dependency Graph

[Visual representation of epic dependencies using Mermaid]

```mermaid
graph LR
    E1[Epic 1] --> E2[Epic 2]
    E2 --> E3[Epic 3]
    E2 --> E4[Epic 4]
    E3 --> E5[Epic 5]
    E4 --> E5
```

---

## Milestone Mapping

### Milestone 1: [Name]
- Epic 1: [Title]
- Epic 2: [Title]
- Epic 3: [Title]

### Milestone 2: [Name]
- Epic 4: [Title]
- Epic 5: [Title]

---

## Execution Instructions

To implement this plan:

1. Start with Epic 1 (no dependencies)
2. Use `/trellis.implement` with the epic document
3. Track progress with `bd` commands
4. Validate completion using the epic's acceptance criteria
5. Proceed to the next unblocked epic

```bash
# Create beads issues for tracking
bd create --title="Epic 1: [Title]" --type=feature --priority=2

# Check what's ready to work on
bd ready
```
```

---

## Epic Sizing

| Size | Scope | Typical Content |
|------|-------|-----------------|
| **Small** | Single focused capability | 1-2 requirements, minimal integration |
| **Medium** | Feature with multiple parts | 3-5 requirements, some integration |
| **Large** | Complex feature or integration | 5+ requirements, significant testing |

Prefer Medium-sized epics. Split Large epics if possible.

---

## Discovery Questions

If the PRD is ambiguous, ask up to 5 clarifying questions before proceeding:

```markdown
**Question [N]:** [Specific question]
**Recommended:** [Your suggested approach]

| Option | Description | Impact on Epics |
|--------|-------------|-----------------|
| A | [First option] | [Effect] |
| B | [Second option] | [Effect] |

Reply with option letter, "yes" to accept, or provide your answer.
```

---

## Key Rules

- Use absolute paths for all file operations
- Each milestone produces 2-3+ epics minimum
- No epic should reference future epic details
- Create the index document before individual epics
- Offer to create beads issues for tracking after generation

---

**Begin by analyzing the user input. If a PRD path is provided, read it and summarize your understanding. Then ask any clarifying questions needed before generating the epic decomposition.**
