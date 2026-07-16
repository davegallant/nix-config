---
description: Review pending changes for security vulnerabilities
argument-hint: "[focus]"
---
Perform a security review of the pending changes on the current branch.

1. Diff the branch against the repository's default branch to see what changed.
2. Look for: injection, broken auth/authorization, secret or credential exposure, unsafe deserialization, path traversal, SSRF, and insecure defaults.
3. For each finding, give the file/line, a severity, why it's exploitable, and a concrete fix.

Report only real, actionable issues — no generic boilerplate. Extra focus: $ARGUMENTS
