---
description: Cleanup-only review of changed code (reuse, simplification, efficiency)
argument-hint: "[target]"
---
Review the changed code for cleanup opportunities and apply the fixes. Quality only — do NOT hunt for bugs.

Look for:
- Reuse: existing helpers/utilities that already do what new code does by hand
- Simplification: dead code, needless indirection, clearer control flow
- Efficiency: obviously wasted work

Diff against the default branch (or the target if given: $ARGUMENTS), apply the improvements, and summarize what you changed and why. Keep every change behavior-preserving.
