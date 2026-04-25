{
  config,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  imports = [
    ./claude.nix
    ./features.nix
    ./fish.nix
    ./git.nix
    ./gui.nix
    ./k9s.nix
    ./nixvim.nix
    ./opencode.nix
    ./obsidian.nix
    ./ghostty.nix
  ];

  home.stateVersion = "25.11";

  services = {
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = true;
      pinentry.package =
        if config.features.headless.enable then pkgs.pinentry-curses else pkgs.pinentry-gnome3;
    };
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
    };

    go = {
      enable = true;
      package = unstable.go;
    };

    fzf = {
      enable = true;
    };

    broot = {
      enable = true;
      enableFishIntegration = true;
      settings.verbs = [
        {
          invocation = "open";
          key = "ctrl-o";
          execution = "$EDITOR {file}";
          leave_broot = false;
        }
      ];
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
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

    weathr = {
      enable = true;
    };
  };
}
