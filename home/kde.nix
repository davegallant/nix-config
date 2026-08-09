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

  # The same idea for opencode Go usage, built to the same package layout so it
  # installs the same way. opencode publishes no usage API, so the widget's
  # helper replays an https://opencode.ai/_server request copied out of the web
  # console as cURL and scrapes the three usage windows from the response. That
  # means it needs configuring after install: right-click the widget ->
  # Configure, paste the curl. Nothing here can provision that -- it carries a
  # live session cookie and goes stale whenever opencode redeploys.
  # No tagged releases; bump rev/hash by hand.
  opencode-usage-widget = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "opencode-usage-widget";
    rev = "24dbbef02df1bf258e6473729481c40919e15148";
    hash = "sha256-0tQj/EJWzsZ1BmO3T069tI9YmbES5Ed/NuGcPdWZkhs=";
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
    xdg.dataFile."plasma/plasmoids/com.davegallant.opencodeusage".source =
      "${opencode-usage-widget}/package";

    xdg.configFile."kscreenlockerrc".text = ''
      [Daemon]
      Autolock=true
      LockOnResume=false
      Timeout=5
    '';
  };
}
