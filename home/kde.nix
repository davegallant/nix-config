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

    # Free Alt+` (KWin's default) for Ghostty's quick terminal, and move
    # KWin's window cycling to Meta+` / Meta+~ only (Super/Cmd+`). Alt+` must
    # not remain as a second binding — KDE treats it as live, and it blocks
    # Meta+`. kglobalaccel owns this file, so patch the keys; it applies on
    # the next login
    home.activation.kwinMoveAltGraveToMeta = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kglobalshortcutsrc --group kwin \
        --key 'Walk Through Windows of Current Application' \
        'Meta+`,none,Walk Through Windows of Current Application'
      run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kglobalshortcutsrc --group kwin \
        --key 'Walk Through Windows of Current Application (Reverse)' \
        'Meta+~,none,Walk Through Windows of Current Application (Reverse)'
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
