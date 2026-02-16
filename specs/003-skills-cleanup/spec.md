# Feature Specification: AI-Native Plugin Redesign

**Feature Branch**: `003-skills-cleanup`
**Created**: 2026-02-16
**Status**: Draft
**Input**: Redesign trellis as an AI-native development workflow plugin. Two-command lifecycle: scope (do the work) and release (ship it). Zero human ceremony between approval and completion.

## Design Philosophy

Trellis should be designed for how AI actually works, not how humans manage projects:

- **One command to start, one to ship** — `scope` handles branch + build + verify + PR. `release` handles merge + tag + publish.
- **Autonomous after approval** — One confirmation, then hands-off until the AI presents a completed, verified solution.
- **Integrated loops over pipelines** — Plan-build-verify in one flow. No sequential handoffs between separate tools.
- **State as memory, not ceremony** — Track state for session recovery, not for human reporting.
- **Parallel by default** — Specialized agents run concurrently where possible.
- **Graceful degradation** — Works without beads, without a test suite, without a dev server. Each layer adds value when available.

## The Workflow

### Primary: 2 commands, 4 human touchpoints

```
/trellis:scope "fix login timeout bug"
  → creates branch (fix/login-timeout)
  → proposes approach                      ← touchpoint: user says "go"
  → implements autonomously (parallel agents, tests, visual verification, self-correction)
  → pushes and creates PR
  → reports results                        ← touchpoint: user reviews summary

/trellis:release
  → analyzes changes, determines version   ← touchpoint: user confirms version
  → merges PR, tags, publishes release
  → reports completion                     ← touchpoint: user sees release URL
```

### Supporting: use when needed

| Skill | When to use |
|-------|-------------|
| `implement` | Add more work to an existing branch ("also add X", "fix reviewer feedback") |
| `status` | Check progress, resume a session, see what's in flight |
| `codemap` | Generate/update codebase navigation map for large projects |
| `init` | First-time project setup (configure beads, set conventions) |

### Escape hatches: manual control

| Skill | When to use |
|-------|-------------|
| `push` | Manual commit/push when you don't want the full scope workflow |
| `pr` | Manual PR creation when you want review before running release |

## Skill Audit

### Remove (6 skills — human ceremony)

| Skill | Reason |
|-------|--------|
| `prd` | Formal PRDs serve human stakeholders. AI gets intent from conversation. |
| `epics` | AI decomposes work naturally. Epics are a human coordination artifact. |
| `import` | Spec-kit bridge. Spec-kit is being removed. |
| `sync` | Bridges two systems. With spec-kit removed and beads optional, nothing to sync. |
| `test-plan` | Human-shaped documentation. Verification is built into the implement loop. |
| `ready` | Absorbed into `status`. |

### Keep and rework (6 skills)

| Skill | Changes |
|-------|---------|
| `implement` | Rework as autonomous plan-build-verify engine. Used by `scope` internally and available standalone. |
| `codemap` | Polish frontmatter and cross-references. No functional changes. |
| `push` | Polish. Demote to escape hatch. |
| `pr` | Polish. Demote to escape hatch. |
| `release` | Polish. Already handles the full merge-tag-publish flow. |
| `status` | Absorb `ready` functionality. Show both project health and unblocked work. |

### Create (1 skill)

| Skill | Purpose |
|-------|---------|
| `scope` | **The primary entry point.** Creates branch, runs implement, pushes, creates PR. One command for the entire build cycle. |

### Update knowledge skills (2 skills)

| Skill | Changes |
|-------|---------|
| `architecture` | Rewrite for AI-native identity. Remove spec-kit references. |
| `style` | Update to remove spec-kit assumptions. |

### Final count

**Before**: 14 (12 user-invocable + 2 knowledge)
**After**: 10 (8 user-invocable + 2 knowledge)
**Removed**: 6 (prd, epics, import, sync, test-plan, ready)
**Created**: 1 (scope)
**Net change**: -4 user-invocable skills

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Scope Is the Single Entry Point (Priority: P1)

A user types `/trellis:scope "description"` and walks away. Trellis creates a branch, proposes an approach, gets one approval, then autonomously implements, tests, visually verifies, self-corrects, pushes, and creates a PR. The user comes back to a completed PR with a summary of what was built.

**Why this priority**: This is the entire product. If scope doesn't work end-to-end, trellis has no value proposition.

**Independent Test**: Invoke scope with a real feature description on a real codebase. Approve the approach. Verify it produces a PR with committed, tested code — without any further human interaction.

**Acceptance Scenarios**:

1. **Given** a user types `/trellis:scope "add a health check endpoint"`, **When** trellis processes the input, **Then** it creates a conventionally-named branch (e.g., `feat/health-check-endpoint`)
2. **Given** a branch is created, **When** trellis proposes an approach, **Then** it waits for a single user confirmation before proceeding
3. **Given** the user approves, **When** scope begins executing, **Then** zero further human input is required until completion
4. **Given** scope is running, **When** it completes all work, **Then** it pushes to remote and creates a PR automatically
5. **Given** scope finishes, **When** it presents results, **Then** the summary includes: what was built, what was tested, what was visually verified, verification results, and any unresolved issues
6. **Given** the description indicates a bug fix (e.g., "fix login timeout"), **When** scope creates a branch, **Then** it uses the `fix/` prefix
7. **Given** beads is available, **When** scope runs, **Then** it creates a beads issue and tracks progress for session recovery
8. **Given** beads is not available, **When** scope runs, **Then** it completes the full lifecycle without errors

---

### User Story 2 - Implement Is the Autonomous Build Engine (Priority: P1)

The implement skill is the engine inside scope. It can also be invoked standalone for "add more to this branch" scenarios. After approval, it runs fully autonomously: builds, tests, visually verifies, self-corrects, and commits.

**Why this priority**: Implement is the core that scope delegates to. Its quality determines everything.

**Independent Test**: On an existing branch, invoke implement with additional work. Verify it runs to completion autonomously with tested, committed code.

**Acceptance Scenarios**:

1. **Given** a user is on an existing branch, **When** they invoke `/trellis:implement "also add rate limiting"`, **Then** it proposes an approach and asks for one confirmation
2. **Given** approval, **When** implement runs, **Then** it completes autonomously with zero further input
3. **Given** implement identifies parallelizable work, **When** it decomposes internally, **Then** it dispatches to specialized agents concurrently
4. **Given** an agent completes a work unit, **When** automated tests exist, **Then** implement runs them and self-corrects on failure (up to 3 retries)
5. **Given** UI changes are made, **When** a dev server is available, **Then** implement uses browser automation to visually verify the result
6. **Given** a verification step fails after retries, **When** implement cannot self-correct, **Then** it documents the issue, commits what works, and continues — never blocks or prompts
7. **Given** all work is complete, **When** implement reports results, **Then** the summary covers: built, tested, visually verified, and unresolved items

---

### User Story 3 - Release Ships the Work (Priority: P1)

After scope creates a PR, the user reviews it and invokes `/trellis:release` to merge, tag, and publish. This is the deliberate shipping gate.

**Why this priority**: Shipping is the final step. It must be reliable and handle errors gracefully.

**Independent Test**: With an open PR on the current branch, invoke release and verify it merges, tags, and creates a GitHub release.

**Acceptance Scenarios**:

1. **Given** a PR exists for the current branch, **When** the user invokes `/trellis:release`, **Then** it analyzes changes and proposes a semantic version
2. **Given** the user confirms the version, **When** release proceeds, **Then** it updates CHANGELOG.md, creates release notes, merges the PR, tags, and creates a GitHub release
3. **Given** no PR exists, **When** release is invoked, **Then** it creates one automatically before proceeding
4. **Given** the PR requires approval, **When** release cannot merge, **Then** it stops and clearly explains the blocker

---

### User Story 4 - Skills Are Consistent and Well-Formed (Priority: P1)

Every skill follows the same conventions: consistent frontmatter, consistent sections, no broken references.

**Why this priority**: Inconsistent skills produce inconsistent AI behavior.

**Independent Test**: Audit every SKILL.md for frontmatter completeness, section ordering, and cross-reference accuracy.

**Acceptance Scenarios**:

1. **Given** any user-invocable skill, **When** its frontmatter is inspected, **Then** it contains `name`, `description`, and `disable-model-invocation: true`
2. **Given** any knowledge skill, **When** its frontmatter is inspected, **Then** it contains `name`, `description`, and `user-invocable: false`
3. **Given** any cross-skill reference, **When** followed, **Then** it resolves to an existing skill
4. **Given** all skills, **When** compared, **Then** they follow consistent section ordering

---

### User Story 5 - Agents Are the Execution Muscle (Priority: P2)

All agents have comprehensive system prompts. No thin stubs. Every agent produces quality work when delegated to by implement.

**Why this priority**: Agents determine output quality.

**Independent Test**: Dispatch a representative task to each agent and evaluate output quality.

**Acceptance Scenarios**:

1. **Given** any implementation agent, **When** reviewed, **Then** it includes: objectives, scope, operating rules, code examples, checklist, and return format
2. **Given** the backend-architect agent, **When** compared to peers, **Then** it has comparable depth
3. **Given** all agents, **When** frontmatter is inspected, **Then** each has `name`, `description`, `tools`, `model`, and `skills` fields

---

### User Story 6 - Clean Repo, No Legacy Debt (Priority: P2)

All spec-kit content, legacy command files, removed skill directories, and stale artifacts are gone.

**Why this priority**: Dead code confuses AI and humans.

**Independent Test**: Verify no files exist outside the expected plugin structure.

**Acceptance Scenarios**:

1. **Given** the cleanup is complete, **When** `.claude/commands/` is inspected, **Then** no speckit command files remain
2. **Given** the cleanup is complete, **When** `.specify/` is checked, **Then** the directory does not exist
3. **Given** the cleanup is complete, **When** `skills/` is listed, **Then** only the expected skill directories exist
4. **Given** docs are reviewed, **Then** no references to spec-kit as a requirement remain

---

### Edge Cases

- What happens when a user invokes a removed skill name (e.g., `/trellis:prd`)? Claude should suggest using `/trellis:scope` instead.
- What happens when scope is invoked while already on a feature branch? It should detect this and ask if the user wants a new scope or to add to the current one.
- What happens when implement encounters a task too large for a single agent? It decomposes further automatically.
- What happens when all retries are exhausted? Implement documents the failure, commits what works, reports the issue — never blocks.
- What happens when no dev server is running? Skip visual checks, rely on code-level verification, note the skip.
- What happens when browser automation tools are unavailable? Degrade to code-only verification.
- What happens when implement breaks previously passing tests? Fix loop: diagnose, patch, re-test, up to retry limit.
- What happens when beads is partially configured? Init detects and offers to complete setup.

## Requirements *(mandatory)*

### Functional Requirements

#### Removals
- **FR-001**: Skills `prd`, `epics`, `import`, `sync`, `test-plan`, and `ready` MUST be removed from `skills/`
- **FR-002**: All spec-kit content MUST be removed: `.claude/commands/speckit.*.md`, `.specify/` directory, spec-kit templates and scripts
- **FR-003**: All references to removed skills MUST be updated or removed across remaining skills, agents, CLAUDE.md, README, and docs
- **FR-004**: No stale files from removed skills or legacy directories MUST remain

#### Plugin Integrity
- **FR-005**: `plugin.json` version MUST be updated to match the release version, license MUST be MIT
- **FR-006**: All skill directories under `skills/` MUST contain a valid `SKILL.md` with YAML frontmatter
- **FR-007**: All agent files under `agents/` MUST contain valid YAML frontmatter with `name`, `description`, `tools`, `model`, and `skills` fields
- **FR-008**: Skills that use beads MUST check for availability and gracefully skip beads-specific steps when not installed

#### Skill Quality
- **FR-009**: Every user-invocable skill MUST include `disable-model-invocation: true` in frontmatter
- **FR-010**: Every knowledge skill MUST include `user-invocable: false` in frontmatter
- **FR-011**: All cross-skill references MUST resolve to existing skills
- **FR-012**: All skills MUST follow consistent section ordering: frontmatter, User Input, Instructions, User Arguments (if applicable), Notes (if applicable)
- **FR-013**: No skill MUST contain unnecessary pseudocode that doesn't serve the AI executing it
- **FR-014**: All skill descriptions MUST accurately reflect what the skill does

#### Scope — The Primary Entry Point
- **FR-015**: A `/trellis:scope` skill MUST be created as the primary entry point for all new work
- **FR-016**: Scope MUST accept a natural language description of the work to be done
- **FR-017**: Scope MUST determine the scope type (feature, fix, refactor, chore) from the description and create a conventionally-named branch (`feat/`, `fix/`, `refactor/`, `chore/`)
- **FR-018**: Scope MUST invoke implement internally after branch creation
- **FR-019**: After implement completes, scope MUST push to remote and create a PR with a structured description
- **FR-020**: Scope MUST optionally create a beads issue when beads is available
- **FR-021**: When invoked on an existing feature branch, scope MUST detect this and ask if the user wants to start a new scope or add to the current branch

#### Implement — The Autonomous Build Engine
- **FR-022**: `/trellis:implement` MUST function as an integrated plan-build-verify loop
- **FR-023**: Implement MUST accept intent from scope (via internal invocation) or from conversation context (standalone invocation)
- **FR-024**: Implement MUST propose an approach and get user confirmation — this is the **only** human interaction point
- **FR-025**: After approval, implement MUST run to completion autonomously with zero further human input
- **FR-026**: Implement MUST decompose work internally and route to specialized agents in parallel where possible
- **FR-027**: Implement MUST commit incrementally after each verified work unit

##### Verification Layers
- **FR-028**: Implement MUST run automated tests (when they exist) after each work unit and self-correct on failure
- **FR-029**: Implement MUST run linting and type checking (when configured) as part of verification
- **FR-030**: Implement MUST use browser automation (Playwright or Chrome DevTools via MCP) to visually verify UI changes when a dev server is available
- **FR-031**: Visual verification MUST compare the rendered result against the stated intent
- **FR-032**: Each verification layer MUST degrade gracefully when its tools are unavailable (note what was skipped in the final report)

##### Self-Correction
- **FR-033**: When verification fails, implement MUST attempt to diagnose and fix automatically (retry loop)
- **FR-034**: Retry limit MUST be bounded (maximum 3 attempts per work unit)
- **FR-035**: When retries are exhausted, implement MUST commit what works, document the failure, and continue — MUST NOT block or prompt

##### Completion Report
- **FR-036**: Implement MUST present a summary: what was built, tested, visually verified, and any unresolved issues
- **FR-037**: Implement MUST optionally track progress in beads when available

#### Status Consolidation
- **FR-038**: `/trellis:status` MUST absorb `ready` functionality (show unblocked work alongside project health)

#### Init
- **FR-039**: `/trellis:init` MUST guide first-time project setup (detect project type, configure beads if available, set conventions)

#### Agent Quality
- **FR-040**: Every implementation agent MUST include: objectives, scope, operating rules, code examples, checklist, and return format
- **FR-041**: The `backend-architect` agent MUST be expanded to match peer depth
- **FR-042**: Agents MUST reference relevant knowledge skills via the `skills` frontmatter field

#### Knowledge Skills
- **FR-043**: `architecture` MUST be rewritten for AI-native identity (remove spec-kit references)
- **FR-044**: `style` MUST be updated to remove spec-kit assumptions

### Key Entities

- **Scope**: A unit of work with a defined intent, branch, and lifecycle (branch → implement → PR → release).
- **Skill**: A directory under `skills/` containing a `SKILL.md` file. Either user-invocable or model-invocable.
- **Agent**: A markdown file under `agents/` defining a specialized subagent.
- **Plugin Manifest**: `plugin.json` under `.claude-plugin/`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Plugin installs with zero errors; exactly 8 user-invocable skills and 2 knowledge skills are discoverable
- **SC-002**: `/trellis:scope` creates a branch, runs implement, pushes, and creates a PR — all from a single command with one user approval
- **SC-003**: `/trellis:implement` runs fully autonomously after approval: builds, tests, visually verifies, self-corrects, commits — zero further human input
- **SC-004**: `/trellis:release` merges, tags, and publishes a GitHub release from an existing PR
- **SC-005**: 100% of skills have complete, consistent frontmatter appropriate to their type
- **SC-006**: Zero cross-reference errors exist between skills
- **SC-007**: Zero spec-kit files or references-as-requirements remain in the repo
- **SC-008**: All implementation agents have comprehensive system prompts (no agent below 60% of median line count)
- **SC-009**: All skills function correctly both with and without beads installed
- **SC-010**: `plugin.json` version and license are current

## Clarifications

### Session 2026-02-16

- Q: Should beads be a hard or soft requirement? → A: Soft requirement. Skills check for availability and skip beads-specific steps if missing.
- Q: Should spec-kit content be kept or removed? → A: Remove all spec-kit content. Referenced only as optional integration.
- Q: Should new skills be prescribed or discovered? → A: Prescribe scope and init; evaluation determines others.
- Q: Should the plugin be designed for human workflows or AI-native? → A: AI-native. Remove human ceremony. Keep what helps AI build software.
- Q: Should implement require human interaction during execution? → A: No. Fully autonomous after approval. Tests, visual verification, self-correction loops — all without human input.
- Q: What should the user-facing workflow look like? → A: Two primary commands. `/trellis:scope` handles branch + build + verify + PR. `/trellis:release` handles merge + tag + publish. Everything else is supporting or escape hatch.

## Assumptions

- Beads is a soft dependency: recommended for session recovery but not required
- Spec-kit is a separate project: all content removed, referenced only as optional external tool
- The Claude Code plugin format is stable and follows documented conventions
- Skills that enforce git conventions have inherent value as infrastructure
- Removed skills represent human ceremony; useful functionality absorbed into scope/implement or dropped
- The smaller skill set improves description character budget usage
- Scope type detection (feat/fix/refactor/chore) can be reliably inferred from natural language descriptions
- Browser automation tools (Playwright, Chrome DevTools MCP) may not be available in all environments; all visual verification is best-effort
