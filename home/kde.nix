{ lib, pkgs, ... }:
let
  # davegallant/claude-usage-widget is a fork of CraigBorrows/claude-usage-widget
  # carrying three local changes as real commits: a circular progress ring in
  # the compact panel, fetching usage from Messages API rate-limit headers
  # instead of the oauth/usage endpoint (that endpoint is rate-limited far more
  # aggressively than ordinary API traffic and 429s under a 60s poll interval),
  # and tinting the popup usage bars green/orange/red at 70%/90%.
  # No tagged releases exist upstream or on the fork; bump rev/hash by hand.
  claude-usage-widget = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "claude-usage-widget";
    rev = "127e30ca78cd4cdfaade9f176c86f8762fb8a732";
    hash = "sha256-gRn740nuFhx2QQ2vl7p+joNmJnX2tllvBqKabibPRbY=";
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
