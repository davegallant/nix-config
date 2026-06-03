{ lib, ... }:

{
  options.features = {
    desktop.enable = lib.mkEnableOption "Linux GUI workstation home bundle (brave, firefox, niri, zed, gnome-keyring, mangohud)";
    headless.enable = lib.mkEnableOption "VM/SSH-only (curses pinentry, fish last_dir restore, skip Docker amd64 default)";
    ai.enable = lib.mkEnableOption "AI tooling for the user (Claude Code, pi, and optionally Ollama)";
    weatherCoords = lib.mkOption {
      type = lib.types.str;
      default = "42.982,-81.249";
      description = "Coordinates used by weather scripts and Waybar weather link.";
    };
  };
}
