{
  lib,
  pkgs,
  ...
}:
{
  xdg.configFile."ghostty/config".text = ''
    command = /run/current-system/sw/bin/fish
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "12"}
    clipboard-trim-trailing-spaces = true
    ${lib.optionalString pkgs.stdenv.isLinux "async-backend = epoll"}
    ${lib.optionalString pkgs.stdenv.isDarwin "# explicit bind works around cmd+v not pasting into the search bar (ghostty#10749)\nkeybind = super+v=paste_from_clipboard"}

    # Agents (claude, codex, pi) ring the bell when they finish or need input:
    # 🔔 in the tab title, a border on the pane, and a Dock bounce
    bell-features = no-system,no-audio,attention,title,border
    unfocused-split-opacity = 0.85

    # Copy Ghostty's terminfo and TERM fallback to SSH hosts, so remotes
    # don't fail with "unknown terminal xterm-ghostty"
    shell-integration-features = cursor,title,path,ssh-env,ssh-terminfo

    # Restore tabs and splits on every relaunch, not only after a crash
    # (macOS-only; the default follows the system "close windows" setting)
    window-save-state = always
    ${lib.optionalString pkgs.stdenv.isDarwin "# left Option sends Alt (Claude's option+p, option+t); right Option still types special characters\nmacos-option-as-alt = left"}
  '';
}
