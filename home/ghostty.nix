{
  lib,
  pkgs,
  ...
}:
let
  darwinConfig = ''
    # explicit bind works around cmd+v not pasting into the search bar (ghostty#10749)
    keybind = super+v=paste_from_clipboard
    # cmd+c falls through to the app when nothing is selected
    keybind = performable:super+c=copy_to_clipboard

    # left Option sends Alt (Claude's option+p, option+t); right Option still types special characters
    macos-option-as-alt = left
    macos-titlebar-style = tabs
  '';
in
{
  xdg.configFile."ghostty/config".text = ''
    command = /run/current-system/sw/bin/fish
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "12"}
    clipboard-trim-trailing-spaces = true
    mouse-hide-while-typing = true
    ${lib.optionalString pkgs.stdenv.isLinux "async-backend = epoll"}

    # Agents (claude, codex, pi) ring the bell when they finish or need input:
    # 🔔 in the tab title, a border on the pane, and a Dock bounce
    bell-features = no-system,no-audio,attention,title,border
    unfocused-split-opacity = 0.85

    # Desktop notification when a long command finishes in an unfocused pane
    notify-on-command-finish = unfocused

    # Copy Ghostty's terminfo and TERM fallback to SSH hosts, so remotes
    # don't fail with "unknown terminal xterm-ghostty"
    shell-integration-features = cursor,title,path,ssh-env,ssh-terminfo

    # Restore tabs and splits on every relaunch, not only after a crash
    # (macOS-only; the default follows the system "close windows" setting)
    window-save-state = always

    # Dump scrollback to a file and open it in the editor
    keybind = ctrl+shift+o=write_scrollback_file:open

    # Dropdown terminal from any app. macOS needs the Accessibility permission;
    # KDE registers it through the GlobalShortcuts portal (approve it once) and
    # needs the background service in nixos.nix
    keybind = global:alt+grave_accent=toggle_quick_terminal
    quick-terminal-size = 75%

    ${lib.optionalString pkgs.stdenv.isDarwin darwinConfig}
  '';
}
