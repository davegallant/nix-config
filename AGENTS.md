# AGENTS.md

Nix Flake configuration for NixOS and macOS, with home-manager and nixvim.

## Project

- Hosts: `hephaestus` (x86_64-linux), `kratos` and `helios` (aarch64-darwin).
- Channels: nixpkgs 26.05 stable plus nixpkgs-unstable.
- Interactive shell: Fish with Starship. Task runner: `just`.
  Agent `Bash` calls run under **zsh**, not Fish — see [Agent Shell](#agent-shell).
- Resolve the current host with `hostname -s` (or `just hosts`), never
  `scutil --get LocalHostName` — that returns `MacBook-Pro`, which is not a flake
  attribute. `nix flake show` reports `darwinConfigurations` as empty here, so do
  not use it to enumerate hosts; read `flake.nix` or run `just hosts`.

## Agent Workflow

- Format Nix changes with `just fmt`; check without rewriting via `just fmt-check`.
  `nix run .#formatter` fails — `formatter` is per-system, so it needs a system suffix.
- Before committing, run `just lint` and `nix flake check --no-build`.
  `nix-instantiate --parse` is syntax-only and will NOT catch undefined variables
  after a refactor; use `nix flake check --no-build` for that.
- The flake only sees git-tracked files. After creating a new file, `git add` it
  (staging is enough, no commit) before any `nix eval`, `nix build`, or
  `nix flake check`, or evaluation fails with `Path 'X' ... is not tracked by Git`.
  Use `just eval-host <host>` to eval a host config without building.
- Do not run Nix builds or rebuilds inside the Pi harness (`nix build`, `just rebuild`, `nixos-rebuild`, or `darwin-rebuild`). Ask the user to run builds outside the harness.
- See [docs/agent-reference.md](docs/agent-reference.md) for rebuild, maintenance, and merge commands.

## Agent Shell

Agent `Bash` calls run under **zsh** with `nomatch` and `EQUALS` enabled, with
nix-provided GNU coreutils ahead of the BSD tools on `PATH` (including on macOS).

- Quote every glob passed as an argument: `--include='*.nix'`, `'.prettierrc*'`,
  `"repos/o/r/contents/f.md?ref=$SHA"`. An unmatched glob aborts the whole command
  before the binary runs (`(eval):1: no matches found:`), which looks like an empty
  result rather than an error. Prefer `rg -g '*.nix'` or the Grep tool.
- Quote separators: bare `echo ===` fails with `== not found`.
- zsh does not word-split unquoted variables. `FLAGS="-a -b"; cmd $FLAGS` passes one
  literal argument — write flags inline or use an array. `PIPESTATUS` is bash-only.
- `stat` is GNU coreutils: use `stat -c %Y`, never BSD `stat -f %m` (on GNU, `-f` is
  `--file-system` and silently prints filesystem stats instead of an mtime). Same
  class of trap for `sed -i` — call `/usr/bin/sed` for BSD behaviour.
- Paths under `~/.claude/projects/` begin with `-`, which tools read as a flag.
  Pass `--` (`head -c N -- "$f"`) or prefix the glob with `./`.
- Don't read `$?` after a pipe — it is the last command's status, not the one you
  care about.

## Sandbox

Sandbox and permission rules live in `home/claude/settings.json` (the nix-managed
source; `~/.claude/settings.json` is generated and denied for editing). Changes need
`just rebuild` plus a new session to take effect.

- Writable: `$TMPDIR`, `/tmp/claude`, and the paths in `sandbox.filesystem.allowWrite` —
  which includes `~/src/github.com/`, so local git operations in sibling clones work.
  That is deliberately broad: you can write to clones unrelated to the current task, so
  confirm the repo you are in before editing.
- Filesystem access is not network access. Remote git operations in any clone still fail
  on the SSH block below, regardless of the write allowlist.
- `origin` is an SSH URL and outbound port 22 is blocked, so `git fetch/push origin`
  always fails. Use the explicit HTTPS URL for remote operations. The following
  `fatal: failed to store: 100001` is the macOS keychain failing to *cache* a token —
  harmless; check the ref-update line to confirm success.
- Deny patterns match anywhere in a compound command, and `*` spans spaces. One
  denied clause kills the whole command, so keep a possibly-denied read in its own
  call. `rm -f` / `rm -rf` are denied: use a fresh unique path, `git rm` for tracked
  files, or `git clone --depth 1 <url> "$TMPDIR/<name>"` with no pre-`rm`.
- `ps aux` and `pgrep` do not work (`requires entitlement` / `sysmond service not
  found`). To test whether a daemon is up, probe its socket or use the client's own
  status subcommand.
- macOS pasteboard access and `tmux` both fail inside the sandbox (`NSPasteboard
  generalPasteboard unavailable`; `fork failed`). Read `home/tmux.nix` instead of
  querying a live server, and ask the user for clipboard checks.
- `go build` and `go test` **do** work — do not claim otherwise without trying.
- MCP servers are not managed by this flake; they live in `~/.claude.json`, which
  holds plaintext credentials. When inspecting it, print server names and `env`
  **keys** only. Never run a bare `env`/`printenv` grep that can match a secret value.

## Layout

- `flake.nix`: inputs, system builders, shared module wiring.
- `nixos.nix` / `darwin.nix`: shared system modules.
- `hosts/*.nix`: host-specific settings.
- `home/`: home-manager modules.
- `packages.nix`: shared package set.

## Nix Conventions

- Use lowercase filenames; prefer single words and `default.nix` for directory entries.
- Use camelCase for variables and functions; use lowercase Greek-mythology host names.
- Prefer standard dot-paths and flat dot-notation for simple enables; use nested sets for related options.
- Use `stdenv.isLinux` directly for Linux-only enables; use `lib.optionals`, `lib.optionalAttrs`, or `lib.optionalString` for conditional values.
- Use `pkgs.foo` by default and `unstable.foo` only when newer packages are needed. Use `${lib.getBin pkg}/bin/name` for service binaries and `input.packages.${pkgs.stdenv.hostPlatform.system}.default` for flake inputs.
- Do not use `assert`; use `lib.mkDefault` only for hardware defaults.
- Keep `#` comments minimal and pragmatic; use package-list section headers and explain non-obvious settings inline.
- `packages.nix` installs on **all** hosts. Anything only one machine needs goes in
  that host's `hosts/<host>.nix`, not here.
- `nixpkgs-unstable` is a flake input, not a registry alias: `nix eval nixpkgs-unstable#foo`
  fails. Use `github:NixOS/nixpkgs/nixos-unstable#foo.version` to query it directly.
- `home.file` with `recursive = true` produces per-file symlinks into the store. Tools
  that walk a directory for manifests may ignore symlinked files (Codex does) — for
  those, use a `home.activation` entry that `cp -rL`s from the store (see `home/codex.nix`).
  Renaming such a file to disable it is undone by the next activation.
- `pi`, `claude`, and `codex` are prebuilt packages that vendor their own docs in the
  nix store; grep those rather than guessing upstream doc URLs. Note `pi` on `PATH` is
  a `writeShellScriptBin` wrapper — the real package is the store path it `exec`s.

## Commits

Commit directly to `main`; do not create feature branches or PRs for routine changes
in this repo. Never push without explicit approval.

Both this repo and `davegallant/skills` are **public**. Never commit employer-internal
hostnames, org names, or repo names into them, including values lifted from subagent
output. A force push does not remove content — the orphaned blob stays fetchable.

Main branch: `main`. Use Conventional Commits: `<type>(<scope>): <summary>`.
Types are `feat`, `fix`, `chore`, `refactor`, `style`, `docs`, `ci`, and `revert`. Use imperative,
lowercase summaries without a trailing period, at most 72 characters.
