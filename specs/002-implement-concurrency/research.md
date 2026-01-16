# Research: Implement Concurrency Enhancement

**Date**: 2026-01-16
**Feature**: 002-implement-concurrency

## Research Topics

1. Parallel Task tool invocation patterns
2. Agent routing best practices
3. Continuous execution loop design
4. Blocker detection and handling

---

## 1. Parallel Task Tool Invocation

### Decision: Use single-message multi-Task pattern

**Rationale**: The Claude Code Task tool documentation and pr-review-toolkit implementation show that parallel execution is achieved by including multiple Task tool calls in a single assistant message. This is the most efficient approach as it:
- Launches all agents simultaneously
- Reduces round-trip latency
- Allows Claude to batch the tool invocations

**Pattern observed in pr-review-toolkit**:
```markdown
**Parallel approach** (user can request):
- Launch all agents simultaneously
- Faster for comprehensive review
- Results come back together
```

**Implementation approach**:
```
FOR batch of independent beads (up to parallel-limit):
  Create single response with multiple Task tool calls:
    Task(subagent_type="frontend-developer", prompt="...", description="Implement bead X")
    Task(subagent_type="backend-architect", prompt="...", description="Implement bead Y")
    Task(subagent_type="database-architect", prompt="...", description="Implement bead Z")
```

**Alternatives considered**:
- Sequential Task calls: Simpler but slower; doesn't leverage parallelism
- Background agents (run_in_background=true): Possible but adds complexity for result aggregation

---

## 2. Agent Routing Best Practices

### Decision: Pattern-based routing with fallback to general-purpose

**Rationale**: The pr-review-toolkit uses specialized agents for specific tasks (code-reviewer, silent-failure-hunter, type-design-analyzer). Each agent has deep expertise in its domain. The same pattern applies to implementation agents.

**Routing rules (from spec AR-001 through AR-009)**:

| Pattern | Agent Type | Model |
|---------|------------|-------|
| `.tsx`, `.jsx`, `.vue`, `.svelte` | frontend-developer | opus |
| API endpoints, services, controllers | backend-architect | opus |
| migrations, schemas, models | database-architect | opus |
| Python code | python-pro | opus |
| TypeScript code | typescript-pro | opus |
| Go code | golang-pro | opus |
| Multi-domain (mixed) | Primary focus specialist | opus |
| Unclear scope | general-purpose | opus |

**Routing algorithm**:
1. Parse bead title and description for file patterns
2. Check for explicit file extensions mentioned
3. Check for domain keywords (API, migration, component, etc.)
4. If multiple domains, identify primary focus (most files/most critical)
5. Fall back to general-purpose if no clear match

**Alternatives considered**:
- User-specified agent per task: Too manual; defeats automation goal
- LLM-based routing: Could work but adds latency; pattern matching sufficient

---

## 3. Continuous Execution Loop Design

### Decision: WHILE loop with blocker-only breaks

**Rationale**: The current implementation already has a WHILE loop (step 9) but includes "ask to continue/retry/stop" prompts that interrupt flow. The enhancement removes these interruptions except for genuine blockers.

**Loop structure**:
```
WHILE open beads exist for this feature:
  ready_beads = bd ready | filter by feature epic

  IF ready_beads is empty AND open beads exist:
    # This is a genuine blocker - all remaining work is blocked
    Display blocker summary (what's blocked, why)
    Ask user for guidance
    BREAK

  # Partition into batches respecting:
  # - parallel-limit (default 3)
  # - file conflicts (serialize conflicting beads)
  # - dependencies (already handled by bd ready)

  FOR each batch:
    Launch parallel agents (single message, multiple Task calls)
    Wait for all agents to complete

    FOR each result:
      IF success:
        Validate (files exist, syntax OK)
        bd close [bead_id]
        Update tasks.md checkbox
        # DO NOT ask user - continue automatically
      ELSE:
        Record failure with notes
        # Continue with next bead - don't stop for single failure

    IF all beads in batch failed:
      # This is a genuine blocker
      Display failure summary
      Ask user: retry / skip / stop
      IF stop: BREAK

  # Phase transition happens automatically (no prompts)
  IF phase epic complete:
    Close phase epic (no user prompt)
```

**Key changes from current behavior**:
- Remove "Handle partial failures: ask to continue/retry/stop" for single failures
- Only prompt on batch-wide failures
- Phase transitions happen silently

**Alternatives considered**:
- Full automation with --force default: Too risky; users should be aware of blockers
- Per-task prompts: Current behavior; too interruptive

---

## 4. Blocker Detection and Handling

### Decision: Explicit blocker categories with actionable messages

**Rationale**: The spec defines BC-001 through BC-005. Each blocker type needs specific detection logic and resolution guidance.

**Blocker detection**:

| Category | Detection | User Message |
|----------|-----------|--------------|
| BC-001: Missing env var | Agent reports env var not set | "Missing environment variable: `VAR_NAME`. Set it and retry." |
| BC-002: External service unavailable | Agent reports connection failure | "Cannot reach `SERVICE`. Check network/credentials and retry." |
| BC-003: Dependency cycle | `bd dep cycles` returns non-empty | "Dependency cycle detected: A → B → A. Resolve in beads and retry." |
| BC-004: All blocked | `bd ready` empty but open beads exist | "All remaining beads are blocked. Blockers: [list]. Resolve dependencies." |
| BC-005: Agent inability | Agent returns failure with explanation | "[Agent] could not complete task: [reason]. Options: retry, modify task, skip." |

**Actionable message format**:
```
⚠️ BLOCKER: [Category]

What happened:
  [Specific issue description]

What was attempted:
  [Agent/operation that failed]

Resolution options:
  1. [Primary resolution]
  2. [Alternative]
  3. Skip this bead and continue
  4. Stop execution

Your choice: [wait for input]
```

**Alternatives considered**:
- Automatic skip on all failures: Would leave incomplete features
- Retry loops: Could infinite loop on persistent failures

---

## 5. Fresh Agent Per Bead

### Decision: Always spawn new agent via Task tool; never resume

**Rationale**: The Task tool creates isolated agent instances. By not using the `resume` parameter, each bead gets a completely fresh agent with no prior context pollution.

**Implementation**:
```
Task(
  subagent_type="[selected-agent]",
  prompt="[full context + task]",
  description="Implement [bead-id]: [title]"
  // NO resume parameter - fresh agent
)
```

**Context provided to each agent**:
- Feature spec summary (from spec.md)
- Relevant plan.md sections for this task
- Data model (if applicable)
- Contracts (if applicable)
- Specific bead requirements and acceptance criteria
- Current file state (agent reads files fresh)

**Alternatives considered**:
- Shared agent with context window: Leads to context pollution
- Resume previous agent: Would carry over assumptions/errors

---

## Summary

All research topics resolved. No NEEDS CLARIFICATION items remain.

| Topic | Decision | Key Pattern |
|-------|----------|-------------|
| Parallel invocation | Single message, multiple Task calls | pr-review-toolkit pattern |
| Agent routing | Pattern-based with general-purpose fallback | File extension + keyword matching |
| Execution loop | WHILE with blocker-only breaks | Continuous until blocked |
| Blocker handling | Categorized with actionable messages | Explicit options per blocker type |
| Fresh agents | New Task per bead, no resume | Isolated context |
