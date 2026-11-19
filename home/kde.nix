{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      kodi
      moonlight-qt
      kdePackages.plasma-browser-integration
      kdePackages.markdownpart
      pwvucontrol
      python3
      wl-clipboard
      xdg-utils
    ];

    # Free Alt+` (KWin's default) for Ghostty's quick terminal. kglobalaccel owns
    # this file, so patch the one key; it applies on the next login
    home.activation.kwinFreeAltGrave = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kglobalshortcutsrc --group kwin \
        --key 'Walk Through Windows of Current Application' \
        'none,Alt+`,Walk Through Windows of Current Application'
    '';

    xdg.configFile."kscreenlockerrc".text = ''
      [Daemon]
      Autolock=true
      LockOnResume=true
      LockGrace=5
      Timeout=10
    '';
  };
}
