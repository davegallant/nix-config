# AGENTS.md

Guidelines for AI coding agents working in this repository.

## Project Overview

Nix Flake configuration for NixOS and macOS systems, with home-manager for
user-level configuration and nixvim for Neovim.

- **Hosts**:
  - `hephaestus`: x86_64-linux NixOS desktop
  - `kratos`: aarch64-darwin macOS
  - `helios`: aarch64-darwin macOS
- **Nix channel**: nixpkgs 26.05 stable, plus nixpkgs-unstable
- **Shell**: Fish with Starship
- **Task runner**: `just`

## Commands

### Rebuild system

```sh
just rebuild    # or: just r
```

Builds first, shows an `nvd diff`, then switches. Uses `nixos-rebuild --sudo`
on Linux and `sudo darwin-rebuild` on macOS.

### Build without switching

```sh
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel
nix build .#darwinConfigurations.kratos.config.system.build.toplevel
nix build .#darwinConfigurations.helios.config.system.build.toplevel
```

### Format

```sh
just fmt        # fd -e nix -x nixfmt
nix fmt         # formatter flake output
```

Formatter: `nixfmt` / `nixfmt-rfc-style`. Run `just fmt` before committing Nix
changes.

### Lint

```sh
just lint       # deadnix, statix, shellcheck tracked *.sh files
```

`statix.toml` disables `repeated_keys` because this repo intentionally favors
flat dot-notation for simple option assignments.

### Update package hashes

```sh
just update-claude [VERSION]
just update-pi [VERSION]
```

### Merge PR

```sh
just merge-pr
```

Squash-merges the current branch's PR and attaches the last `nvd diff` output.

## Validation

There are no automated tests. Primary validation is a successful `just rebuild`.
Before committing, run the relevant checks:

```sh
just fmt
just lint
nix flake check --no-build
```

CI checks formatting and linting, builds `hephaestus`, `kratos`, and `helios`,
and pushes build outputs to Cachix on `main`.

## Repository Layout

- `flake.nix`: flake inputs, system builders, shared module wiring
- `nixos.nix`: shared NixOS module
- `darwin.nix`: shared nix-darwin module
- `hosts/*.nix`: host-specific settings
- `home/`: home-manager modules
- `packages.nix`: shared package set

## Code Style

### Naming

- **Files**: lowercase, single-word preferred (`fish.nix`, `git.nix`); use
  `default.nix` as directory entry point.
- **Directories**: lowercase; use kebab-case for multi-word names.
- **Variables/functions**: camelCase (`mkUnstable`, `hmModule`, `extraModules`).
- **Hosts**: Greek mythology, lowercase (`hephaestus`, `kratos`, `helios`).
- **Nix options**: standard dot-path convention (`services.tailscale.enable`).

### Comments

- Use `#` single-line comments only.
- Keep comments minimal and pragmatic.
- Use section headers in package lists when helpful: `# essentials`, `# cloud`,
  `# gaming`, etc.
- Add inline comments for non-obvious settings: `false; # breaks timezone`.

### Platform conditionals

- Use `stdenv.isLinux` directly on `enable` for Linux-only features:
  ```nix
  programs.firefox.enable = stdenv.isLinux;
  ```
- Use `lib.optionals stdenv.isLinux [ ... ]` for conditional list items.
- Use `lib.optionalAttrs stdenv.isLinux { ... }` for conditional attribute sets.
- Use `lib.optionalString stdenv.isLinux "..."` for conditional strings.
- Prefer direct conditionals over `lib.mkIf`. Exception: `lib.mkIf` is fine as a
  whole-module guard, e.g. `config = lib.mkIf stdenv.isLinux { ... }`.

### Package references

- `pkgs.foo`: stable nixpkgs, default for most packages.
- `unstable.foo`: nixpkgs-unstable for packages needing newer versions.
- Binary paths in services: `"${lib.getBin pkg}/bin/name"`.
- Flake input packages:
  `input.packages.${pkgs.stdenv.hostPlatform.system}.default`.

### Attribute sets

Use flat dot-notation for simple single-attribute enables:

```nix
services.printing.enable = true;
```

Use nested sets when configuring multiple sub-attributes:

```nix
services.tailscale = {
  enable = true;
  package = unstable.tailscale;
};
```

### Error handling

- Do not use `assert` statements.
- Use `lib.mkDefault` sparingly for hardware defaults.

## Git Conventions

- Main branch: `main`
- Use Conventional Commits for commit messages.

Format:

```text
<type>(<scope>): <summary>
```

- **type**: `feat`, `fix`, `chore`, `refactor`, `style`, `docs`, `ci`, or
  `revert`.
- **scope**: optional affected module or host, e.g. `hephaestus`, `fish`,
  `nixvim`.
- **summary**: imperative mood, lowercase, no trailing period, ≤72 chars total.

Examples:

```text
feat(hephaestus): add borgmatic backup service
fix(fish): correct SSH_AUTH_SOCK fallback on darwin
chore: bump nixpkgs flake input
refactor(nixvim): split keybindings into separate file
style: run nixfmt across all nix files
ci: cache davegallant/nix-config in Cachix
```
