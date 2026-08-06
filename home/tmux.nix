{
  lib,
  pkgs,
  hostname,
  ...
}:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    customPaneNavigationAndResize = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      continuum
    ];
    extraConfig = ''
      set -g default-command "${pkgs.fish}/bin/fish"

      # Don't let an SSH-forwarded agent leak into this persistent session:
      # KeePassXC's ssh-agent (home/keepassxc-ssh-agent.nix) should always
      # win inside tmux, even after the forwarding connection dies and
      # leaves a dead socket behind.
      set -g update-environment "DISPLAY XAUTHORITY"

      # update-environment only covers what a client copies into the
      # *session* environment on attach. Whatever forked the server has
      # already been copied into the *global* environment table, and that
      # copy lives as long as the server does, so a server started from a
      # Tailscale SSH login hands every later pane that login's forwarded
      # socket - long after it stops existing. Pin it back to the local
      # agent.
      #
      # A server started from an SSH login (Tailscale or otherwise) inherits
      # that login shell's environment wholesale, which may never have had
      # XDG_RUNTIME_DIR set. Every client tool that talks to a per-user
      # runtime service (wpctl/pactl -> pipewire, etc.) breaks silently in
      # every pane of that session. Pin it the same way SSH_AUTH_SOCK is
      # pinned below, so a plain `prefix+r` repairs an already-broken
      # session without needing to kill the server.
      run-shell '${pkgs.tmux}/bin/tmux set-environment -g XDG_RUNTIME_DIR "''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"'

      # This goes through run-shell rather than the more obvious
      # `set-environment -g SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent"`
      # because tmux expands $VAR in config strings against the server's
      # own environment: a server that starts without XDG_RUNTIME_DIR
      # collapses that to "/ssh-agent". Inside single quotes tmux leaves
      # the string alone and sh does the expansion, so the :- fallback
      # actually applies. Both binaries are absolute because run-shell
      # inherits the server's PATH, which is not guaranteed to be useful.
      run-shell '${pkgs.tmux}/bin/tmux set-environment -g SSH_AUTH_SOCK "''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}/ssh-agent"'

      # Terminal + titles
      set -as terminal-features ",xterm-256color:RGB"
      set -g set-titles on
      set -g set-titles-string "#S:#I:#W - #{pane_current_command}"
      set-window-option -g automatic-rename on

      # Windows + panes
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g detach-on-destroy off
      set -g display-panes-time 800
      set -g display-time 2000
      set -g xterm-keys on
      set -g monitor-activity on
      set -g visual-activity off

      # Splits open in the current path
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Quality-of-life bindings
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux.conf reloaded"
      bind S choose-tree -Zs
      bind W choose-tree -Zw
      bind-key -n C-S-Left previous-window
      bind-key -n C-S-Right next-window

      # Keep the selection highlighted after a mouse drag instead of
      # exiting copy-mode immediately (default copy-pipe-and-cancel clears it)
      unbind -T copy-mode-vi MouseDragEnd1Pane
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-no-clear

      # resurrect / continuum: auto-save session state and restore it whenever
      # a fresh tmux server starts (e.g. after a host reboot)
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-strategy-vim 'session'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'

      # Minimal bottom status line
      set -g status-position bottom
      set -g status 2
      set -g status-format[0] "#[fg=#313244]#{R:─,#{client_width}}"
      set -g status-format[1] "#[align=left range=left #{E:status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{E:window-status-style}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]#{?loop_last_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},#{E:window-status-current-style},#{E:window-status-style}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?loop_last_flag,,#{window-status-separator}}}#[nolist align=right range=right #{E:status-right-style}]#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"
      set -g status-interval 5
      set -g status-style "bg=default,fg=#585b70"
      set -g status-left-length 40
      set -g status-left "#[fg=#89b4fa]#S#[fg=#585b70]│"
      # status-right is deliberately NOT set here - see the mkOrder 750
      # block below for why it has to be set before the plugins load.
      setw -g window-status-format "#[fg=#6c7086]#I:#W"
      setw -g window-status-current-format "#[fg=#89b4fa]#I:#W"
      setw -g window-status-separator " "
      setw -g pane-border-style "fg=#313244"
      setw -g pane-active-border-style "fg=#313244"
      setw -g window-style "default"
      setw -g window-active-style "default"
      set -g pane-border-status off
      set -g pane-border-lines single
      set -g message-style "bg=default,fg=#cdd6f4"
    '';
  };

  # continuum has no timer of its own: it drives periodic saves by prepending
  # a "#(continuum_save.sh)" interpolation onto status-right, which tmux then
  # re-evaluates every status-interval. home-manager renders extraConfig
  # (mkAfter, 1500) *after* the plugin run-shell lines (default, 1000), so
  # setting status-right in extraConfig overwrites that hook right after
  # continuum installs it and auto-save silently never fires again.
  #
  # mkOrder 750 lands between the module's own config (mkBefore, 500) and the
  # plugin block, so status-right already holds this value when continuum
  # loads and continuum prepends to it instead of being clobbered by it.
  # The interpolation renders as an empty string, so it costs no visible
  # width and status-right-length only bounds rendered output anyway.
  xdg.configFile."tmux/tmux.conf".text = lib.mkOrder 750 ''
    set -g status-right-length 40
    set -g status-right "#[fg=#585b70]│#[fg=#a6e3a1]#h"
  '';

  systemd.user.services.tmux-server = lib.mkIf (hostname == "hephaestus") {
    Unit.Description = "Persistent tmux server";
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      # TMUX_TMPDIR decides the socket path, and home-manager's
      # programs.tmux.secureSocket (on by default on Linux) only exports it
      # via home.sessionVariables - which reaches login shells but never
      # this unit. Without it systemd starts a second server on
      # /tmp/tmux-$UID that nothing ever attaches to, while every
      # interactive tmux talks to one on $XDG_RUNTIME_DIR, so this unit
      # silently stops being the persistent server it claims to be. %t is
      # that runtime dir, and lingering is enabled for this user, so the
      # socket survives logout.
      #
      # XDG_RUNTIME_DIR isn't reliably in the systemd user manager's
      # activation environment this early at boot (it can land there after
      # this unit runs), and tmux bakes whatever it sees at `new-session`
      # into its environment table for the life of the server. Set it
      # explicitly via %t, which systemd always resolves correctly.
      #
      # SSH_AUTH_SOCK is pinned for the same reason as in tmux.conf, but
      # set here too so the session's first pane has it immediately rather
      # than racing the run-shell that fixes it up.
      Environment = [
        "XDG_RUNTIME_DIR=%t"
        "TMUX_TMPDIR=%t"
        "SSH_AUTH_SOCK=%t/ssh-agent"
      ];
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.tmux}/bin/tmux -f %h/.config/tmux/tmux.conf has-session -t main 2>/dev/null || ${pkgs.tmux}/bin/tmux -f %h/.config/tmux/tmux.conf new-session -d -s main'";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
