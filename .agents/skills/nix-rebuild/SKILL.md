---
name: nix-rebuild
description: Rebuild this NixOS/nix-darwin config with just rebuild, troubleshoot failures, roll back, and understand nvd diff output. Use when the user wants to rebuild their system, fix a build error, roll back a generation, or check what changed after a rebuild.
---

# nix-rebuild

Skill for working with a Nix flake config managed by `just`. Run all commands
from the repo root.

## Default Action: Run `just rebuild`

When the user asks to **rebuild**, **build**, **apply**, **switch**, or any
similar request without further qualification, immediately run:

```bash
just rebuild
```

Do not ask clarifying questions. Do not offer a menu of options. Do not
substitute a raw `nix build` or `nixos-rebuild` invocation. Just run
`just rebuild` from the repo root and report the result.

## Hosts

| Host | Arch | OS |
|------|------|----|
| `hephaestus` | x86_64-linux | NixOS desktop |
| `kratos` | aarch64-linux | NixOS Parallels VM |
| `ares` | aarch64-darwin | macOS |

## Key Commands

### Rebuild (build → diff → switch)
```bash
just rebuild        # or: just r
```
Runs in three steps:
1. Build: `nixos-rebuild --sudo build --flake . --option warn-dirty false`
2. Diff: `nvd diff /run/current-system result` → saved to `/tmp/nvd-diff.txt`
3. Switch: `nixos-rebuild --sudo switch --flake . --option warn-dirty false`

On macOS, `sudo darwin-rebuild` is used instead of `nixos-rebuild --sudo`.

### Build only (no switch — good for checking errors)
```bash
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel
nix build .#nixosConfigurations.kratos.config.system.build.toplevel
nix build .#darwinConfigurations.ares.config.system.build.toplevel
```

### Roll back to previous generation
```bash
just rollback
```

### Rebuild and install bootloader
```bash
just rebuild-boot
```

### Format all Nix files (run before committing)
```bash
just fmt
```

### Garbage collect
```bash
just clean      # user + root nix-collect-garbage -d
```

## Feature Flags (Two-Tier System)

Changes must be made at **both** levels independently when relevant.

### NixOS-level (`modules/features.nix`)
Set in host configs. Controls system services.
```nix
features.desktop.enable = true;
features.ai.enable = true;
features.ai.ollama.enable = true;
```

### Home-manager-level (`home/features.nix`)
Set via `home-manager.users.<name>.features`. Controls user programs.
```nix
home-manager.users.dave.features = {
  desktop.enable = true;   # brave, firefox, niri, zed, gnome-keyring, mangohud
  headless.enable = true;  # curses pinentry, last_dir restore, skip Docker amd64
  ai.enable = true;        # claude code, pi
};
```

## Common Troubleshooting

### Build error — identify the failing derivation
```bash
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel 2>&1 | tail -40
```

### Check what an option evaluates to
```bash
nix eval .#nixosConfigurations.hephaestus.config.<option.path>
```

### Dirty tree warnings
`--option warn-dirty false` is already baked into `just rebuild`. Add it
manually when running raw `nixos-rebuild`.

### Hash mismatch after editing a package
```bash
just update-claude [VERSION]
just update-pi [VERSION]
```

### Unfree packages blocked
Unfree packages are allowed globally via `nixpkgs.config.allowUnfree = true`.

## Reading nvd diff Output

After a rebuild, diff is saved to `/tmp/nvd-diff.txt`. Key symbols:
- `<<< old-pkg` — removed
- `>>> new-pkg` — added
- Lines with version changes show old → new

```bash
cat /tmp/nvd-diff.txt
```

## Code Style Reminders

- Formatter: `nixfmt` (RFC 166). Run `just fmt` before committing.
- Prefer `pkgs.foo` (stable); use `unstable.foo` only when a newer version is needed.
- Linux-only options: `enable = stdenv.isLinux;` or `lib.optionals stdenv.isLinux`.
- Flat dot-notation for single attributes; nested `= { ... };` for multiple.
- Conventional Commits for all git messages (see `commit` skill).
