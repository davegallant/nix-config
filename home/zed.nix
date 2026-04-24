{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  config =
    lib.mkIf (config.features.desktop.enable && stdenv.isLinux && stdenv.hostPlatform.isx86_64)
      {
        programs.zed-editor = {
          enable = true;
          package = unstable.zed-editor;
          extensions = [
            "ansible"
            "dockerfile"
            "html"
            "make"
            "material-icon-theme"
            "nix"
            "toml"
            "vue"
          ];
          userSettings = {
            icon_theme = "Material Icon Theme";
            vim_mode = true;
            vim = {
              use_system_clipboard = "on_yank";
            };
            autosave = "on_focus_change";
            format_on_save = "off";
            ui_font_size = 18;
            buffer_font_size = 16;
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
      };
}
