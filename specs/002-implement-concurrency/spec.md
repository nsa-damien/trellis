# Feature Specification: Implement Concurrency Enhancement

**Feature Branch**: `002-implement-concurrency`
**Created**: 2026-01-16
**Status**: Draft
**Input**: User description: "Refine /trellis.implement command to work through all open beads until complete, use fresh agents per bead, route to appropriate agent types, and maximize parallel execution"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Continuous Execution Until Completion (Priority: P1)

A developer invokes `/trellis.implement` and the command processes all open beads continuously without stopping, only pausing when a genuine blocker requires human input. The system maintains a clear execution loop that persists until all work is done.

**Why this priority**: This is the core behavioral change - eliminating unnecessary pauses creates a smooth, uninterrupted implementation experience that maximizes throughput.

**Independent Test**: Can be tested by running `/trellis.implement` on a feature with multiple beads and verifying that execution continues automatically through all ready tasks without stopping for confirmation between tasks.

**Acceptance Scenarios**:

1. **Given** a feature with 10 open beads and no blockers, **When** user runs `/trellis.implement`, **Then** all 10 beads are processed in sequence/parallel until complete without user intervention
2. **Given** a feature with open beads where one has an unresolvable dependency (e.g., requires API key not configured), **When** user runs `/trellis.implement`, **Then** system pauses at that specific blocker, explains the issue, and asks for guidance
3. **Given** a feature with multiple phases, **When** phase 1 completes, **Then** execution automatically continues to phase 2 without stopping
4. **Given** all beads are complete, **When** execution finishes, **Then** system displays final summary and generates test plan

---

### User Story 2 - Fresh Agent Per Bead (Priority: P1)

Each bead task is executed by a fresh agent instance, ensuring clean context and preventing state pollution between tasks. This mirrors the pattern used in pr-review-toolkit where each review aspect gets its own dedicated agent.

**Why this priority**: Fresh agents per task are critical for reliability - accumulated context can cause confusion, missed requirements, or incorrect assumptions carrying forward.

**Independent Test**: Can be verified by examining the agent invocations in verbose mode to confirm each bead spawns a new agent via the Task tool.

**Acceptance Scenarios**:

1. **Given** bead A requires TypeScript changes and bead B requires database schema changes, **When** both are executed, **Then** each uses a separate agent instance with no shared state
2. **Given** an agent encounters an error on bead A, **When** bead B is executed next, **Then** bead B's agent starts with clean context unaffected by A's failure
3. **Given** bead A modifies a configuration file, **When** bead B needs to read that file, **Then** bead B's agent reads the current file state (not cached from another agent)

---

### User Story 3 - Intelligent Agent Routing (Priority: P1)

The system automatically selects the most appropriate specialized agent for each bead based on the task type, file patterns, and work description. This ensures domain expertise is applied to each task.

**Why this priority**: Using specialized agents (frontend-developer for UI, database-architect for schemas, etc.) improves implementation quality and accuracy.

**Independent Test**: Can be tested by running implementation with mixed task types and verifying the correct specialized agent is selected for each.

**Acceptance Scenarios**:

1. **Given** a bead involving React component creation (.tsx files), **When** executed, **Then** the frontend-developer agent is selected
2. **Given** a bead involving API endpoint implementation, **When** executed, **Then** the backend-architect agent is selected
3. **Given** a bead involving database migration, **When** executed, **Then** the database-architect agent is selected
4. **Given** a bead involving Python code changes, **When** executed, **Then** the python-pro agent is selected
5. **Given** a bead with unclear scope (e.g., "update configuration"), **When** executed, **Then** the general-purpose agent is used as fallback

---

### User Story 4 - Maximized Parallel Execution (Priority: P2)

The system executes as many non-conflicting beads concurrently as possible, using a single message with multiple Task tool calls (following the same pattern as pr-review-toolkit's parallel review mode).

**Why this priority**: Parallel execution dramatically reduces total implementation time for large features with independent tasks.

**Independent Test**: Can be verified by running `/trellis.implement` on a feature with multiple independent tasks and observing that multiple agents are launched simultaneously.

**Acceptance Scenarios**:

1. **Given** 3 independent beads (no file conflicts or dependencies), **When** executed, **Then** all 3 agents are launched in a single message with 3 parallel Task tool calls
2. **Given** 5 independent beads and default parallel-limit of 3, **When** executed, **Then** first batch of 3 runs in parallel, then second batch of 2 runs in parallel
3. **Given** bead A modifies file X and bead B also modifies file X, **When** detected, **Then** A and B are serialized (not run in parallel)
4. **Given** bead A is a dependency of bead B, **When** detected, **Then** B waits for A to complete before starting
5. **Given** user specifies `--parallel-limit 5`, **When** 8 independent tasks exist, **Then** batches of 5 and 3 are executed

---

### User Story 5 - Graceful Blocker Handling (Priority: P2)

When a genuine blocker requiring human input is encountered, the system clearly explains the issue, what was attempted, and asks for specific guidance before resuming.

**Why this priority**: Clear blocker communication prevents user frustration and enables quick resolution.

**Independent Test**: Can be tested by intentionally creating a scenario with a missing dependency and verifying the blocker message is actionable.

**Acceptance Scenarios**:

1. **Given** execution encounters a missing environment variable required by a task, **When** detected, **Then** system displays: the specific blocker, what was attempted, clear options for resolution
2. **Given** user provides resolution to a blocker, **When** execution resumes, **Then** the blocked task is retried and execution continues
3. **Given** all remaining beads are blocked by unresolved dependencies, **When** detected, **Then** system displays blocked status and exits gracefully

---

### Edge Cases

- What happens when an agent fails mid-execution of a bead? System marks bead as failed with notes, asks user to continue/retry/stop.
- What happens when parallel agents have conflicting outputs? File conflict detection prevents this by serializing conflicting tasks.
- What happens when beads daemon is unavailable? System falls back to tasks.md-only mode with warning.
- What happens when user presses Ctrl+C during parallel execution? All running agents are terminated, in_progress beads are left in that state for resume.
- What happens when a dependency cycle is detected? System reports the cycle and suggests resolution.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST process all open beads continuously without stopping between tasks unless a blocker requiring human input is encountered
- **FR-002**: System MUST spawn a fresh agent instance for each bead task using the Task tool
- **FR-003**: System MUST select the most appropriate specialized agent type for each bead based on task characteristics
- **FR-004**: System MUST launch multiple agents in parallel using a single message with multiple Task tool calls when tasks are independent
- **FR-005**: System MUST detect file conflicts between tasks and serialize conflicting tasks
- **FR-006**: System MUST respect dependency relationships from beads when ordering execution
- **FR-007**: System MUST display clear, actionable information when encountering a blocker
- **FR-008**: System MUST support resuming from the last point when execution is interrupted
- **FR-009**: System MUST update both beads and tasks.md status after each task completion
- **FR-010**: System MUST respect the `--parallel-limit N` parameter (default: 3) for maximum concurrent agents

### Agent Routing Rules

- **AR-001**: Tasks involving `.tsx`, `.jsx`, `.vue`, `.svelte` files route to frontend-developer
- **AR-002**: Tasks involving API endpoints, services, controllers route to backend-architect
- **AR-003**: Tasks involving migrations, schemas, database models route to database-architect
- **AR-004**: Tasks primarily involving Python code route to python-pro
- **AR-005**: Tasks primarily involving TypeScript code route to typescript-pro
- **AR-006**: Tasks primarily involving Go code route to golang-pro
- **AR-007**: Tasks with unclear scope use general-purpose agent as fallback
- **AR-008**: All implementation agents use Opus model for quality
- **AR-009**: Multi-domain tasks route to the primary focus specialist; that agent handles secondary concerns within the same task

### Blocker Categories

- **BC-001**: Missing environment variables or configuration
- **BC-002**: External service unavailable
- **BC-003**: Dependency cycle detected
- **BC-004**: All remaining tasks blocked by unresolved dependencies
- **BC-005**: Agent reports inability to complete task

### Key Entities

- **Bead**: An issue tracked in the beads system representing a unit of work with status, dependencies, and metadata
- **Agent**: A specialized subprocess launched via Task tool to execute a specific task
- **Batch**: A group of independent beads executed in parallel within a single message
- **Blocker**: A condition that prevents automatic continuation and requires human input

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developer can complete a 10-task feature implementation with a single `/trellis.implement` invocation (no manual restarts needed)
- **SC-002**: Independent tasks execute in parallel, reducing total execution time compared to sequential processing
- **SC-003**: Each specialized task type is handled by the appropriate agent (verified in verbose output)
- **SC-004**: When blockers occur, 90% of blocker messages contain actionable information (specific issue + resolution options)
- **SC-005**: Resume functionality allows continuation within 30 seconds of prior interruption point

## Clarifications

### Session 2026-01-16

- Q: When a bead involves multiple technologies (e.g., React component AND database schema), how should agent selection work? → A: Route to primary focus specialist; agent handles secondary concerns

## Assumptions

- The beads daemon is typically available but fallback to tasks.md-only mode is acceptable
- Users have access to the Task tool and can spawn specialized agents
- File conflict detection is based on task descriptions and may require some inference
- The default parallel-limit of 3 balances throughput with system resources
