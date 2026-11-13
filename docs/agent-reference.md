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
main outputs to Cachix. Pushes made with `GITHUB_TOKEN` trigger no workflows, so
`update-hashes.yml` and `flake-update.yml` dispatch `cachix.yml` on their branch
after pushing; without that, bot PRs would merge with an unbuilt head commit.

## Maintenance

```sh
just update-claude [VERSION]
just update-codex [VERSION]
just update-hunk [VERSION]
just update-litra [VERSION]
just update-pi [VERSION]
just update-pvectl        # bump the flake input, then rebuild
just update-skills        # bump superpowers + mattpocockSkills; review before rebuilding
```

Renovate opens the version bumps for the `update-*` packages above on its own;
these recipes are for bumping by hand. A weekly workflow opens `flake.lock` PRs
for every input except the two skill inputs, which are bumped by hand only.

Routine changes go straight to `main`. For a bot PR (Renovate or `flake.lock`),
a human squash-merges it with the latest `nvd` diff attached; agents do not run this:

```sh
just merge-pr
```
