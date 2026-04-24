# AGENTS.md

Guidelines for AI coding agents working in this repository.

## Project Overview

Nix Flake-based configuration managing NixOS (Linux) and macOS (nix-darwin) systems
with home-manager for user-level configuration. Uses nixvim for Neovim configuration.

- **Hosts**: `hephaestus` (x86_64-linux NixOS desktop), `kratos` (aarch64-linux NixOS Parallels VM), `zelus` (aarch64-darwin macOS)
- **Nix channel**: nixpkgs 25.11 (stable), plus unstable channel
- **Shell**: Fish (primary), with Starship prompt
- **Task runner**: `just` (not Make)

## Build / Rebuild / Lint Commands

### Rebuild system (primary build command)
```sh
just rebuild    # or: just r
```
On Linux runs `nixos-rebuild --sudo switch --flake .`
On macOS runs `sudo darwin-rebuild switch --flake .`

### Rebuild and install bootloader
```sh
just rebuild-boot
```
Runs `$cmd boot --flake . --install-bootloader`. Use after bootloader changes.

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

### Update flake inputs
```sh
just update     # or: just u (runs update-flake.sh)
```
`update-flake.sh` is interactive: stashes uncommitted changes, `git pull`, `nix flake update`, `just rebuild`, then prompts to GPG-sign and push a timestamped commit. Do not run non-interactively.

### Garbage collection
```sh
just clean
```

### Rollback to previous generation
```sh
just rollback
```

### Tests
There are no automated tests in this repository. The primary validation is
a successful `just rebuild`. CI builds the NixOS configuration and pushes
to Cachix on every push to `main`.

## Repository Structure

```
flake.nix          # Entry point: inputs, outputs, system configurations
                   # Exports: formatter, devShells, nixosModules,
                   #          nixosConfigurations, darwinConfigurations
packages.nix       # Shared system packages (cross-platform + Linux-only)
justfile           # Task runner commands
home/              # home-manager modules (one concern per file)
  default.nix      # Aggregates all home modules via imports list
  fish.nix         # Fish shell + Starship prompt
  firefox.nix      # Librewolf browser config
  git.nix          # Git configuration
  k9s.nix          # k9s Kubernetes TUI
  niri.nix         # Niri Wayland compositor + Waybar/Fuzzel/Mako/Swaylock
  nixvim.nix       # Neovim (nixvim) configuration
  opencode.nix     # `oc` wrapper: runs opencode via Docker
  zed.nix          # Zed editor configuration
hosts/             # Per-machine system configurations (flat files, not dirs)
  hephaestus.nix   # NixOS desktop (x86_64-linux)
  kratos.nix       # NixOS Parallels VM (aarch64-linux)
  zelus.nix        # macOS (nix-darwin)
modules/           # Reusable NixOS modules (exported as nixosModules flake output)
  features.nix     # Feature flags (desktop, ai, ollama)
  ollama.nix       # Ollama with ROCm acceleration
overlays/          # Nixpkgs overlays
  default.nix      # Overlay entry point
  cd-fzf/          # Custom package
  niri-float-sticky/ # Custom package (Go, niri window management)
```

## Code Style Guidelines

### Formatter
Use `nixfmt-rfc-style` (RFC 166). Run `just fmt` to format all `.nix` files.

### Indentation
2 spaces. No tabs.

### Function arguments
- Always include `...` (extra args catch-all) in module function signatures.
- Single-line for 1-2 named arguments: `{ pkgs, ... }:`
- Multi-line (one per line) for 3+ arguments:
  ```nix
  {
    pkgs,
    lib,
    unstable,
    ...
  }:
  ```

### `let`/`in` blocks
Each keyword on its own line:
```nix
{ pkgs, ... }:
let
  inherit (pkgs) stdenv;
in
{
  ...
}
```

### `with` keyword
Only use `with` in list contexts (e.g., `with pkgs; [ ... ]`). Never use `with`
to scope an entire attribute set.

### `inherit` keyword
Prefer `inherit (pkgs) stdenv;` over `stdenv = pkgs.stdenv;`.

### Imports
Use relative paths in list form:
```nix
imports = [
  ./fish.nix
  ./git.nix
];
```

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

### Module Structure
- One concern per file in `home/` (e.g., one program = one file).
- `default.nix` aggregates sub-modules via an `imports` list.
- Host configs are flat single files, not directories.
- Shared config is factored into `packages.nix` and `home/default.nix`.
- The `mkSharedModules` function in `flake.nix` assembles shared modules
  for both NixOS and Darwin configurations.
- Reusable NixOS modules live in `modules/` and are exported as
  `nixosModules` in the flake output. They are auto-imported into all
  NixOS configurations via `builtins.attrValues` — adding a new module
  to `modules/` and registering it in the `nixosModuleSet` attrset in
  `flake.nix` is sufficient; no per-host import is needed.

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
- Triggers on push to `main` (ignoring markdown/LICENSE changes)
- Builds the NixOS `hephaestus` configuration on `ubuntu-latest`
- Pushes build artifacts to the `davegallant` Cachix binary cache

## Git Conventions
- Main branch: `main`
- GPG-signed commits enforced
- Pull rebase by default
- Flake description and comments: all lowercase
