# Quickstart: Testing the Enhanced /trellis.implement

**Feature**: 002-implement-concurrency
**Date**: 2026-01-16

## Prerequisites

1. **Trellis plugin installed**: Ensure trellis is available in your Claude Code environment
2. **Beads CLI available**: `bd --version` should work
3. **A test feature with beads imported**: Run `/trellis.import` on a feature first

## Testing the Enhanced Command

### Test 1: Continuous Execution (P1)

**Setup**:
1. Create or use a feature with 5+ tasks
2. Ensure no blockers exist
3. Run `/trellis.import` if not already imported

**Test**:
```
/trellis.implement
```

**Expected behavior**:
- All ready tasks execute without prompting between tasks
- Phase transitions happen automatically
- Execution only stops when all tasks complete or a blocker is encountered
- Final summary and test plan generated at completion

**Pass criteria**: No "continue?" prompts between successful tasks

---

### Test 2: Fresh Agent Per Bead (P1)

**Setup**:
1. Use a feature with at least 2 tasks of different types (e.g., one TypeScript, one Python)

**Test**:
```
/trellis.implement --verbose
```

**Expected behavior**:
- Each task shows a separate `Task` tool invocation
- No `resume` parameter in Task calls
- Different agent types for different task types

**Pass criteria**: Verbose output shows distinct Task calls for each bead

---

### Test 3: Agent Routing (P1)

**Setup**:
1. Create a feature with mixed task types:
   - A task mentioning `.tsx` files
   - A task mentioning `API endpoint`
   - A task mentioning `migration`

**Test**:
```
/trellis.implement --verbose
```

**Expected behavior**:
- `.tsx` task → `frontend-developer` agent
- API task → `backend-architect` agent
- Migration task → `database-architect` agent

**Pass criteria**: Agent types match task characteristics

---

### Test 4: Parallel Execution (P2)

**Setup**:
1. Create a feature with 3+ independent tasks (no dependencies, no shared files)

**Test**:
```
/trellis.implement --parallel-limit 3
```

**Expected behavior**:
- Multiple agents launched simultaneously
- Tasks complete faster than sequential execution would allow

**Pass criteria**: Observe parallel agent launches in output

---

### Test 5: File Conflict Serialization (P2)

**Setup**:
1. Create two tasks that both mention the same file (e.g., both modify `config.json`)

**Test**:
```
/trellis.implement --verbose
```

**Expected behavior**:
- The two conflicting tasks execute in separate batches
- No parallel execution of conflicting tasks

**Pass criteria**: Conflicting tasks run sequentially, not in parallel

---

### Test 6: Blocker Handling (P2)

**Setup**:
1. Create a task with an unresolvable dependency (e.g., requires external API key)
2. Or create a dependency cycle

**Test**:
```
/trellis.implement
```

**Expected behavior**:
- Execution pauses at the blocker
- Clear message explaining what's blocked and why
- Options provided: retry, skip, stop

**Pass criteria**: Blocker message is actionable with clear options

---

### Test 7: Resume After Interruption (P2)

**Setup**:
1. Start `/trellis.implement` on a multi-task feature
2. Press Ctrl+C during execution

**Test**:
```
/trellis.implement --continue
```

**Expected behavior**:
- Execution resumes from where it left off
- Completed tasks are not re-executed
- In-progress task is retried or skipped (user choice)

**Pass criteria**: Resume picks up from interruption point

---

## Quick Validation Commands

```bash
# Check beads are set up
bd ready

# View feature epic
bd show [ROOT_EPIC_ID]

# Check for dependency cycles
bd dep cycles

# View blocked tasks
bd blocked
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No beads integration found" | Run `/trellis.import` first |
| Beads daemon not responding | Try `bd sync --status` or restart daemon |
| All tasks blocked | Check `bd blocked` and resolve dependencies |
| Agent routing incorrect | File an issue; fallback to general-purpose works |
