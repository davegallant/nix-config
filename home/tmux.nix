{ pkgs, ... }:
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
    ];
    extraConfig = ''
      set -g default-command "${pkgs.fish}/bin/fish"

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

      # resurrect
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-strategy-vim 'session'

      # Minimal bottom status line
      set -g status-position bottom
      set -g status 2
      set -g status-format[0] "#[fg=#313244]#{R:─,#{client_width}}"
      set -g status-format[1] "#[align=left range=left #{E:status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{E:window-status-style}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]#{?loop_last_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},#{E:window-status-current-style},#{E:window-status-style}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?loop_last_flag,,#{window-status-separator}}}#[nolist align=right range=right #{E:status-right-style}]#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"
      set -g status-interval 5
      set -g status-style "bg=default,fg=#585b70"
      set -g status-left-length 40
      set -g status-left "#[fg=#89b4fa]#S#[fg=#585b70]│"
      set -g status-right-length 40
      set -g status-right "#[fg=#585b70]│#[fg=#a6e3a1]#h"
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
}
