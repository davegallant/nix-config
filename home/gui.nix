{ lib, pkgs, ... }:
{
  imports = [
    ./brave.nix
    ./firefox.nix
    ./kde.nix
    ./zed.nix
  ];

  config = lib.mkIf pkgs.stdenv.isLinux {
    services.gnome-keyring = {
      enable = true;
      components = [
        "secrets"
      ];
    };

    programs.mangohud = {
      enable = true;
      settings = {
        font_size = 24;
        position = "top-right";
        toggle_hud = "Shift_R+F1";
      };
    };
  };
}
