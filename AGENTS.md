# AGENTS.md

Guidelines for AI coding agents working in this repository.

## Project Overview

Nix Flake-based configuration managing NixOS (Linux) and macOS (nix-darwin) systems
with home-manager for user-level configuration. Uses nixvim for Neovim configuration
and LiteLLM as a local model proxy for AI tooling.

- **Hosts**: `hephaestus` (x86_64-linux NixOS desktop), `kratos` (aarch64-linux NixOS Parallels VM), `zelus` (aarch64-darwin macOS)
- **Nix channel**: nixpkgs 25.11 (stable), plus unstable channel
- **Shell**: Fish, with Starship prompt
- **Task runner**: `just` (not Make)

## Build / Rebuild / Lint Commands

### Rebuild system (primary build command)

```sh
just rebuild    # or: just r
```

Runs a two-step process: builds first, shows an `nvd diff` of package changes,
then switches. On Linux uses `nixos-rebuild --sudo`, on macOS uses
`sudo darwin-rebuild`.

### Build without switching (CI / dry-run)

```sh
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel
```

### Format all Nix files

```sh
just fmt        # runs: fd -e nix -x nixfmt
nix fmt         # alternative: uses formatter flake output
```
The formatter is `nixfmt` (RFC 166 style, package `nixfmt-rfc-style`).
Always run `just fmt` before committing changes.

### Update package hashes

```sh
just update-claude [VERSION]    # update home/claude/package.nix
just update-pi[VERSION]         # update home/pi/package.nix
just refresh-models             # fetch live LiteLLM model metadata
```

### Merge PR (usually proposed by Renovate)

```sh
just merge-pr
```

Squash-merges the current branch's PR and attaches the last `nvd diff` output.

### Tests
There are no automated tests in this repository. The primary validation is
a successful `just rebuild`. CI builds the NixOS configuration and pushes
to Cachix on every push to `main`.

## Feature Flags (Two-Tier System)

Feature flags exist at **two levels** that must be set independently:

### NixOS-level (`modules/features.nix`)
Set directly in host configs. Controls system services and NixOS modules.
```nix
features.desktop.enable = true;      # NixOS desktop bundle (nixos-gui.nix)
features.ai.enable = true;           # LiteLLM service
features.ai.ollama.enable = true;    # Ollama with ROCm
```

### Home-manager-level (`home/features.nix`)

Set via `home-manager.users.<name>.features`. Controls user-level programs.

```nix
home-manager.users.dave.features = {
  desktop.enable = true;   # brave, firefox, niri, zed, gnome-keyring, mangohud
  headless.enable = true;  # curses pinentry, last_dir restore, skip Docker amd64
  ai.enable = true;        # claude code, pi
};
```

Also provides `remoteHost` (default: `"kratos"`) and `weatherCoords`.

## Code Style Guidelines

### Formatter

Run `just fmt` to format all `.nix` files.

### Naming Conventions

- **Files**: lowercase, single-word preferred (`fish.nix`, `git.nix`). Use `default.nix` as directory entry point.
- **Directories**: lowercase. Kebab-case for multi-word (`cd-fzf`).
- **Variables/functions**: camelCase (`mkUnstable`, `hmModule`, `extraModules`).
- **Host names**: Greek mythology, lowercase (`hephaestus`, `zelus`).
- **NixOS options**: standard dot-path convention (`services.tailscale.enable`).

### Comments

- Use `#` single-line comments only. No `/* */` block comments.
- Keep comments minimal and pragmatic.
- Use section headers in package lists: `# essentials`, `# cloud`, `# gaming`, etc.
- Add inline comments for non-obvious settings: `false; # breaks timezone`

### Platform Conditionals

- Use `stdenv.isLinux` directly on `enable` for Linux-only features:
  ```nix
  programs.firefox.enable = stdenv.isLinux;
  ```
- Use `lib.optionals stdenv.isLinux [ ... ]` for conditional list items.
- Use `lib.optionalAttrs stdenv.isLinux { ... }` for conditional attribute sets.
- Use `lib.optionalString stdenv.isLinux "..."` for conditional strings.
- Prefer direct conditionals over `lib.mkIf`. Exception: `lib.mkIf` is acceptable as a whole-module guard (e.g., `config = lib.mkIf stdenv.isLinux { ... }` in `niri.nix`).

### Package References

Two nixpkgs tiers, passed via `specialArgs`/`extraSpecialArgs`:
- `pkgs.foo` -- stable (default for most packages)
- `unstable.foo` -- nixpkgs-unstable (for packages needing newer versions)
- Binary paths in services: `"${lib.getBin pkg}/bin/name"`
- Flake input packages: `input.packages.${pkgs.stdenv.hostPlatform.system}.default`

### Attribute Set Style

- Flat dot-notation for simple single-attribute enables:
  ```nix
  services.printing.enable = true;
  ```
- Nested `= { ... };` when configuring multiple sub-attributes:
  ```nix
  services.tailscale = {
    enable = true;
    package = unstable.tailscale;
  };
  ```

### Error Handling
- No `assert` statements are used in this codebase.
- Use `lib.mkDefault` sparingly for hardware defaults.

## CI/CD

GitHub Actions workflow (`.github/workflows/cachix.yml`):
- Triggers on push to `main` and on pull requests (ignoring markdown/LICENSE changes)
- Checks formatting with `nix fmt -- --check .`
- Builds the NixOS `hephaestus` and macOS `zelus` configurations, evaluates `kratos`
- Pushes build artifacts to the `davegallant` Cachix binary cache

A separate workflow (`.github/workflows/update-hashes.yml`) runs on PRs touching
`home/claude/package.nix` or `home/pi/package.nix` and recomputes
per-platform hashes before CI runs.

## Updates

Flake inputs are updated automatically by Renovate and auto-merged when CI passes.

## Git Conventions

- Main branch: `main`
- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.

### Format

```
<type>(<scope>): <short summary>
```

- **type**: one of the types below (required)
- **scope**: optional, names the affected module or host (e.g. `hephaestus`, `fish`, `nixvim`)
- **summary**: imperative mood, lowercase, no trailing period, ≤72 chars total

### Types

| Type       | When to use |
|------------|-------------|
| `feat`     | Add a new package, module, or feature |
| `fix`      | Correct broken behavior or configuration |
| `chore`    | Maintenance with no user-visible effect (hash bumps, flake updates) |
| `refactor` | Restructure config without changing behavior |
| `style`    | Formatting-only changes (`just fmt`) |
| `docs`     | Changes to documentation only |
| `ci`       | Changes to GitHub Actions workflows |
| `revert`   | Revert a previous commit |

### Examples

```
feat(hephaestus): add borgmatic backup service
fix(fish): restore last_dir on headless hosts
chore: bump nixpkgs flake input
refactor(nixvim): split keybindings into separate file
style: run nixfmt across all nix files
ci: cache davegallant/nix-config in Cachix
```
