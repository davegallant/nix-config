{ lib, pkgs, ... }:
let
  # davegallant/claude-usage-widget is a fork of CraigBorrows/claude-usage-widget
  # carrying two local changes as real commits: a circular progress ring in the
  # compact panel, and fetching usage from Messages API rate-limit headers
  # instead of the oauth/usage endpoint (that endpoint is rate-limited far more
  # aggressively than ordinary API traffic and 429s under a 60s poll interval).
  # No tagged releases exist upstream or on the fork; bump rev/hash by hand.
  claude-usage-widget = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "claude-usage-widget";
    rev = "6f9abddb6bccd1a3cee9eb37c6637b13a4fd517f";
    hash = "sha256-OKtmkV0fp8tOQm+XIMYr2IHZAIUI69q5nRVp11IJ3Ts=";
  };
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      gnome-calculator
      kodi
      moonlight-qt
      pwvucontrol
      python3
      wl-clipboard
      xclip
      xdg-utils
    ];

    # A single directory symlink, not recursive = true: KPackage's
    # path-traversal guard canonicalizes each file and rejects anything whose
    # real path escapes the package root, which recursive per-file symlinks
    # into the Nix store would trigger.
    xdg.dataFile."plasma/plasmoids/com.cbo.claudeusage".source = "${claude-usage-widget}/package";

    xdg.configFile."kscreenlockerrc".text = ''
      [Daemon]
      Autolock=true
      LockOnResume=false
      Timeout=5
    '';
  };
}
