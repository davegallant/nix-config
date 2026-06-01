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
    ./borgmatic.nix
    ./claude.nix
    ./features.nix
    ./fish.nix
    ./ghostty.nix
    ./git.nix
    ./gui.nix
    ./gh-clone.nix
    ./hunk.nix
    ./k9s.nix
    ./nix-search.nix
    ./nixvim.nix
    ./obsidian.nix
    ./pi.nix
  ];

  home.stateVersion = "26.05";

  services = {
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = !config.features.headless.enable;
      pinentry.package =
        if config.features.headless.enable then pkgs.pinentry-curses else pkgs.pinentry-gnome3;
    };
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    man.enable = stdenv.isLinux;

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

    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    weathr = {
      enable = true;
    };
  };
}
