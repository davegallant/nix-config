{ lib, ... }:

{
  options.features = {
    desktop.enable = lib.mkEnableOption "Linux GUI workstation home bundle (brave, firefox, niri, zed, gnome-keyring, mangohud)";
    ai.enable = lib.mkEnableOption "AI tooling for the user (Claude Code, pi, and optionally Ollama)";
    weatherCoords = lib.mkOption {
      type = lib.types.str;
      default = "42.982,-81.249";
      description = "Coordinates used by weather scripts and Waybar weather link.";
    };
  };
}
