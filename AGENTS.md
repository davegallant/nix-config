# AGENTS.md

Nix Flake configuration for NixOS and macOS, with home-manager and nixvim.

## Project

- Hosts: `hephaestus` (x86_64-linux), `kratos` and `helios` (aarch64-darwin).
- Channels: nixpkgs 26.05 stable plus nixpkgs-unstable.
- Shell: Fish with Starship. Task runner: `just`.

## Agent Workflow

- Format Nix changes with `just fmt`.
- Before committing, run `just lint` and `nix flake check --no-build`.
- Do not run Nix builds or rebuilds inside the Pi harness (`nix build`, `just rebuild`, `nixos-rebuild`, or `darwin-rebuild`). Ask the user to run builds outside the harness.
- See [docs/agent-reference.md](docs/agent-reference.md) for rebuild, maintenance, and merge commands.

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

## Commits

Main branch: `main`. Use Conventional Commits: `<type>(<scope>): <summary>`.
Types are `feat`, `fix`, `chore`, `refactor`, `style`, `docs`, `ci`, and `revert`. Use imperative,
lowercase summaries without a trailing period, at most 72 characters.
