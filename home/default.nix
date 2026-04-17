{
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  imports = [
    ./fish.nix
    ./firefox.nix
    ./git.nix
    ./nixvim.nix
    ./niri.nix
    ./opencode.nix
    ./wakeup.nix
    ./zed.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    just
  ];

  services = {
    gnome-keyring = {
      enable = stdenv.isLinux;
      components = [
        "secrets"
      ];
    };
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = true;
    };
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    direnv.enable = true;

    go = {
      enable = true;
      package = unstable.go;
    };

    fzf = {
      enable = true;
    };

    zathura = {
      enable = stdenv.isLinux;
      options = {
        selection-clipboard = "clipboard";
      };
    };

    nnn = {
      enable = stdenv.isLinux;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      bookmarks = {
        d = "~/Downloads";
        p = "~/src/";
        c = "~/.config";
        h = "~";
      };
      extraPackages = with pkgs; [
        bat
        eza
        fzf
        imv
        mediainfo
        ffmpegthumbnailer
      ];
      plugins = {
        src = "${pkgs.nnn.src}/plugins";
        mappings = {
          p = "preview-tui";
          o = "fzopen";
        };
      };
    };

    mangohud = {
      enable = stdenv.isLinux;
      settings = {
        font_size = 16;
        position = "top-right";
        toggle_hud = "Shift_R+F1";
      };
    };

    weathr = {
      enable = true;
    };
  };
}
