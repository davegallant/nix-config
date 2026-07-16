---
description: Verify a change works by exercising it end-to-end
argument-hint: "[what changed]"
---
Verify that the recent change actually works by exercising it end-to-end — don't rely on tests or typecheck alone.

1. Identify the affected user-facing flow (context: $ARGUMENTS).
2. Drive that flow the way it runs in reality — run the command, hit the endpoint, render the UI — and observe the actual output.
3. Report what you ran, what you observed, and whether it does what it should. If you couldn't exercise it, say so explicitly rather than assuming.
