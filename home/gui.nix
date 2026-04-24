{ config, lib, ... }:
{
  imports = [
    ./firefox.nix
    ./niri.nix
    ./zed.nix
  ];

  config = lib.mkIf config.features.desktop.enable {
    services.gnome-keyring = {
      enable = true;
      components = [
        "secrets"
      ];
    };

    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
      };
    };

    programs.mangohud = {
      enable = true;
      settings = {
        font_size = 16;
        position = "top-right";
        toggle_hud = "Shift_R+F1";
      };
    };
  };
}
