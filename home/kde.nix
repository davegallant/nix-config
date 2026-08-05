{ lib, pkgs, ... }:
let
  # davegallant/claude-usage-widget is a fork of CraigBorrows/claude-usage-widget
  # carrying four local changes as real commits: a circular progress ring in
  # the compact panel, fetching usage from Messages API rate-limit headers
  # instead of the oauth/usage endpoint (that endpoint is rate-limited far more
  # aggressively than ordinary API traffic and 429s under a 60s poll interval),
  # tinting the popup usage bars alongside the ring and labels, and grading
  # that tint on projected end-of-window usage rather than the raw percentage
  # (a port of Claude-Usage-Tracker's UsageStatusCalculator, so the KDE widget
  # warns on the same pace the macOS menu bar app does).
  # No tagged releases exist upstream or on the fork; bump rev/hash by hand.
  claude-usage-widget = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "claude-usage-widget";
    rev = "efcb168b1d604b3115810dedc602597514d12cfb";
    hash = "sha256-lAqjKIlEFK8kc3TfyWLl92RA5gVcKnTcGfJ0+6FEk4c=";
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
