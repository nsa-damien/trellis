---
name: trellis.style
description: Trellis working conventions (sync, commits, safety, formatting)
user-invocable: false
---

Working conventions:
- Prefer beads-driven workflows; don’t mark tasks complete in tasks.md unless beads says closed.
- Preserve formatting when editing markdown: only change what you must.
- For sync operations, keep tasks.md edits minimal (checkbox only) and avoid reformatting.
- For side-effect operations (git push, releases), be conservative and prompt for confirmation at decision points.

Session completion:
- Work is not complete until `git push` succeeds.
