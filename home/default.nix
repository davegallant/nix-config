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
    ./borgmatic.nix
    ./claude.nix
    ./fish.nix
    ./ghostty.nix
    ./git.nix
    ./gui.nix
    ./gh-clone.nix
    ./hunk.nix
    ./k9s.nix
    ./nix-search.nix
    ./nixvim.nix
    ./pi.nix
    ./tmux.nix
  ];

  home.stateVersion = "26.05";

  services = {
    # SSH support is handled by services.ssh-agent (see home/keepassxc-ssh-agent.nix)
    # instead: gpg-agent's ssh-agent emulation can't add/remove identities on
    # request, which KeePassXC's SSH Agent integration relies on.
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      pinentry.package = pkgs.pinentry-gnome3;
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
