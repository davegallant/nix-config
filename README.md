# nix-config

This repo stores nix configuration to manage my hosts running [NixOS](https://nixos.org/) and macOS.

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a personal workstation or a server environment.

```console
❯ macchina

        a8888b.           Host        -  dave@hephaestus
       d888888b.          Machine     -  Micro-Star International Co., Ltd MS-7C02 1.0
       8P"YP"Y88          Kernel      -  6.12.61
       8|o||o|88          Distro      -  NixOS 25.11 (Xantusia)
       8'    .88          DE          -  KDE
       8`._.' Y8.         Packages    -  1 (cargo), 10998 (nix)
      d/      `8b.        Shell       -  fish
     dP        Y8b.       Terminal    -  alacritty
    d8:       ::88b.      Resolution  -  2560x1440, 3840x2160
   d8"         'Y88b      Uptime      -  26m
  :8P           :888      CPU         -  AMD Ryzen 7 5700X 8-Core Processor (16)
   8a.         _a88P      CPU Load    -  8%
 ._/"Yaa     .| 88P|      Memory      -  10.7 GB / 32.8 GB
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

## Update

To update nixpkgs defined in [flake.nix](./flake.nix), run:

```sh
just update
```

If there are updates, they should be reflected in [flake.lock](./flake.lock).

## Rollback

To rollback to the previous generation:

```sh
just rollback
```

## Garbage collection

To cleanup previous files, run nix garbage collection:

```sh
just clean
```

## Restoring from a live USB

If the bootloader for some reason breaks (i.e. motherboard firmware upgrade), restore it from a live USB by running the following commands:

```console
$ sudo cryptsetup luksOpen /dev/nvme0n1p2 crypted-nixos
Enter passphrase for /dev/nvme0n1p2: ********
$ sudo mount /dev/vg/root /mnt
$ sudo mount /dev/nvme0n1p1 /mnt/boot/efi
$ sudo mount /dev/vg/home /mnt/home
$ sudo nixos-enter /mnt
$ hostname <hostname>
```

Navigate to the nix-config directory and run:

```sh
just rebuild-boot
```
