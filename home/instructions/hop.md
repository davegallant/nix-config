
# One session per repo

Sessions are filed by the directory they started in. Before you edit, commit, or
run a multi-step task in a repo other than the one this session started in, hand
the work to a new session there instead of doing it from here:

    agent-hop --agent <claude|codex|pi> <owner/repo|path> "<handoff prompt>"

- Pass your own harness as `--agent`. It opens a Ghostty tab, or starts a
  background Claude session (`claude attach <id>`) outside Ghostty.
- Write the handoff prompt for a reader with no context: the goal, what you
  found so far (paths, links, errors), constraints the user stated, and what
  "done" looks like.
- Then stop working on that task here and tell the user in one line where it
  went.
- Don't hop for read-only lookups in another repo, when the user asks you to
  stay in this session, or when you are a subagent.
