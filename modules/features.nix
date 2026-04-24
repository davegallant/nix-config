{ config, lib, ... }:

{
  options.features = {
    desktop.enable = lib.mkEnableOption "Linux GUI workstation NixOS bundle (niri, xdg portals, audio, fcitx5, bluetooth, flatpak, graphics, printing, avahi, Steam, desktop apps, fonts, greetd)";
    ai = {
      enable = lib.mkEnableOption "AI tooling system services (LiteLLM exposing Copilot models)";
      ollama.enable = lib.mkEnableOption "Ollama with ROCm acceleration (requires features.ai.enable; AMD GPU host only)";
    };
  };

  config = {
    assertions = [
      {
        assertion = !config.features.ai.ollama.enable || config.features.ai.enable;
        message = "features.ai.ollama.enable requires features.ai.enable.";
      }
    ];
  };
}
