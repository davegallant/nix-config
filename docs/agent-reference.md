# Agent Reference

Open this reference only when the task needs one of these operational details.

## System Operations

Rebuild and switch the current system:

```sh
just rebuild # or: just r
```

This builds first, writes an `nvd diff` to `/tmp/nvd-diff.txt`, then switches
with `nixos-rebuild` on Linux or `darwin-rebuild` on macOS.

Build a host without switching:

```sh
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel
nix build .#darwinConfigurations.kratos.config.system.build.toplevel
nix build .#darwinConfigurations.helios.config.system.build.toplevel
```

Do not run these commands inside the Pi harness.

## Validation

```sh
just fmt
just lint
nix flake check --no-build
```

`just lint` runs `deadnix`, `statix`, and ShellCheck for tracked shell scripts.
`statix.toml` disables `repeated_keys` because this repository deliberately
uses flat dot-notation for simple option assignments.

CI formats and lints all Nix files, builds all three hosts, and pushes main
outputs to Cachix.

## Maintenance

```sh
just update-claude [VERSION]
just update-pi [VERSION]
just update-codex [VERSION]
```

To squash-merge the current branch's pull request and attach the latest `nvd`
diff, run:

```sh
just merge-pr
```
