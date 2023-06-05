{pkgs, ...}: {
  users.users."dave.gallant".home = "/Users/dave.gallant";
  imports = [
    ./brew.nix
    ./preferences.nix
  ];
}
