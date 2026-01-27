---
name: trellis.architecture
description: Trellis invariants, data flow, and integration rules (spec-kit ↔ beads)
user-invocable: false
---

Trellis bridges spec-kit planning with beads issue tracking for Claude Code.

Core flow:
- spec-kit `tasks.md` → `/trellis.import` → beads issues
- `/trellis.implement` → dependency-aware execution and completion
- `/trellis.sync` → reconcile beads ↔ tasks.md status

Invariants:
- Beads is the source of truth for task state once imported.
- `FEATURE_DIR/beads-mapping.json` is the authoritative mapping between tasks.md IDs and beads IDs.
- `tasks.md` checkboxes should only be updated to reflect beads status.
- A feature root epic should not be closed until test plan generation is complete.

Repository landmarks:
- `specs/`: per-feature specs (spec.md, plan.md, tasks.md, beads-mapping.json)
- `.beads/`: beads DB
- `docs/`: architecture and release notes
