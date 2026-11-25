# Agent Reference

Open this reference only when the task needs one of these operational details.

## System Operations

Rebuild and switch the current system:

```sh
just rebuild # or: just r
```

This builds first, writes an `nvd diff` to `nvd-diff.txt` under `$XDG_RUNTIME_DIR`
(or `$TMPDIR`), then switches.
Linux switches with `nixos-rebuild switch`; macOS builds with `darwin-rebuild`,
then activates with `nix-env --set` and `./result/activate`.

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
just check   # fmt-check, lint, test, then nix flake check --no-build --all-systems
just eval-host hephaestus   # one host's drvPath; works across OSes
```

`just lint` and `just check` need the flake devShell (`direnv allow`, or
`nix develop -c just check`), which provides `deadnix` and `statix`.
`just lint` runs `deadnix`, `statix`, and ShellCheck for shell scripts.
`statix.toml` disables `repeated_keys` because this repository deliberately
uses flat dot-notation for simple option assignments. `just test` runs the pi
extension tests with Node's built-in runner; Node strips the TypeScript types.

CI checks formatting, lints, runs the pi tests, builds all three hosts, and pushes
main outputs to Cachix.

## Maintenance

```sh
just update               # flake inputs + prebuilt tools + agent-stuff pin; review, then rebuild
just update-flake         # every flake input except skills, agora, and pinned kokoro
just update-tools         # every prebuilt tool (home/*/update-hashes.sh), in parallel
just update-tool TOOL [VERSION]   # one tool by home/ dir name: claude, codex, hunk, litra-autotoggle, pi
just update-agent-stuff   # agent-stuff pin in home/pi.nix to the tip of main
just update-skills        # bump superpowers + mattpocockSkills; review before rebuilding
```

`just update` bumps everything at once; the single-tool recipes bump one thing.
The skill inputs are bumped by hand only, with `just update-skills`.

Routine changes go straight to `main`. For a PR, a human squash-merges it with
the latest `nvd` diff attached; agents do not run this:

```sh
just merge-pr
```
