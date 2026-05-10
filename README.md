# nix-config

This repo stores nix configuration to manage my hosts running [NixOS](https://nixos.org/) and macOS.

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a personal workstation or a server environment.

```console
❯ macchina

        a8888b.           Host        -  dave@hephaestus
       d888888b.          Machine     -  Micro-Star International Co., Ltd MS-7C02 1.0
       8P"YP"Y88          Kernel      -  6.12.81
       8|o||o|88          Distro      -  NixOS 25.11 (Xantusia)
       8'    .88          DE          -  Niri
       8`._.' Y8.         Packages    -  1 (cargo), 6 (flatpak), 9299 (nix)
      d/      `8b.        Shell       -  fish
     dP        Y8b.       Terminal    -  .ghostty-wrappe
    d8:       ::88b.      Resolution  -  3840x2160
   d8"         'Y88b      Uptime      -  11h 32m
  :8P           :888      CPU         -  AMD Ryzen 7 5700X 8-Core Processor (16)
   8a.         _a88P      CPU Load    -  3%
 ._/"Yaa     .| 88P|      Memory      -  10.2 GB / 32.8 GB
 \    YP"    `|     `.
 /     \.___.d|    .'
 `--..__)     `._.'
```

## Prerequisites

- [NixOS](nixos.org) (Linux)
- [Determinate Nix](https://determinate.systems/nix-installer) (macOS)
- [just](https://github.com/casey/just)

## Build

To run a build/rebuild:

```sh
just rebuild
```

## Updates

Updates are proposed by [renovate](https://github.com/renovatebot/renovate). To build the system, checkout the renovate PR and run `just rebuild`.

If the build is stable, run `just merge-pr`.

## Common Recipes

Run `just` to view all recipes and associated descriptions:

```console
❯ just
Available recipes:
    clean                    # run nix garbage collection (user + root)
    fmt                      # format all nix files [alias: f]
    merge-pr                 # squash-merge current branch's PR with nvd diff in body
    rebuild                  # build, show nvd diff, then switch [alias: r]
    rebuild-boot             # rebuild and install bootloader
    refresh-models           # ~/.config/nix-config/litellm-models.json
    rollback                 # switch to previous generation
    update-claude *version   # usage: just update-claude [VERSION]  (VERSION without leading 'v'; defaults to latest)
    update-pi *version       # usage: just update-pi [VERSION]  (VERSION without leading 'v'; defaults to latest)
```

## Restoring from a live USB

If the bootloader for some reason breaks (i.e. motherboard firmware upgrade), restore it from a live USB by running the following commands:

```console
$ sudo cryptsetup luksOpen /dev/nvme0n1p2 crypted-nixos
Enter passphrase for /dev/nvme0n1p2: ********
$ sudo mount /dev/vg/root /mnt
$ sudo mount /dev/nvme0n1p1 /mnt/boot/efi
$ sudo nixos-enter --root /mnt
$ hostname <hostname>
```

Navigate to the nix-config directory and run:

```sh
just rebuild-boot
```
