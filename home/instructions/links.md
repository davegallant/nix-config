# Link references

Whenever a response mentions a GitHub or Slack item, include a clickable link to it.
A bare name, number, or "the thread in #channel" is not enough.

- GitHub: link PRs, issues, commits, workflow runs, and releases by full URL
  (`https://github.com/<owner>/<repo>/pull/<n>`). For code, use a permalink pinned
  to a commit SHA, not a branch: `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<start>-L<end>`.
  Resolve the SHA with `git rev-parse HEAD` or `gh api`, never guess it.
- Slack: link the specific message permalink
  (`https://<workspace>.slack.com/archives/<channel-id>/p<ts-without-dot>`), adding
  `?thread_ts=<ts>&cid=<channel-id>` for thread replies. Prefer the `permalink` field
  from the Slack tool result over building one.
- Jira, Confluence, Datadog, and other web tools follow the same rule: link what you cite.
- Never invent a URL. If you cannot get a real link, say the link is unavailable and
  give the identifiers you have (repo + PR number, channel + timestamp).
- Local files in the current repo keep the `path:line` form; this rule is for
  items that live on a remote service.
