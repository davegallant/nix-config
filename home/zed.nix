{ unstable, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = unstable.zed-editor;
    extensions = [
      "ansible"
      "comment"
      "dockerfile"
      "html"
      "make"
      "material-icon-theme"
      "nix"
      "toml"
      "vue"
    ];
    userSettings = {
      auto_update = false;
      icon_theme = "Material Icon Theme";
      vim_mode = true;
      vim = {
        use_system_clipboard = "on_yank";
      };
      autosave = "on_focus_change";
      format_on_save = "off";
      ui_font_size = 18;
      buffer_font_size = 16;
      disable_ai = true;
      project_panel = {
        dock = "left";
      };
      # Offline: hide sign-in/collab UI and disable telemetry
      title_bar = {
        show_sign_in = false;
        show_user_menu = false;
        show_user_picture = false;
      };
      collaboration_panel.button = false;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
    userKeymaps = [
      {
        context = "Editor && !menu";
        bindings = {
          "ctrl-shift-c" = "editor::Copy";
          "ctrl-shift-x" = "editor::Cut";
          "ctrl-shift-v" = "editor::Paste";
          "ctrl-z" = "editor::Undo";
        };
      }
      {
        context = "vim_mode == normal";
        bindings = {
          "g space" = "editor::OpenExcerpts";
          "shift-v" = "vim::ToggleVisualLine";
        };
      }
    ];
  };
}
