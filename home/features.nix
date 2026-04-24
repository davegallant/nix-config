{ lib, ... }:

{
  options.features = {
    desktop.enable = lib.mkEnableOption "Linux GUI workstation home bundle (firefox, niri, zed, gnome-keyring, zathura, mangohud)";
    headless.enable = lib.mkEnableOption "VM/SSH-only (curses pinentry, fish last_dir restore, skip Docker amd64 default)";
    ai.enable = lib.mkEnableOption "AI tooling for the user (Claude Code, OpenCode, and optionally Ollama)";
  };
}
