{
  config,
  lib,
  unstable,
  ...
}:
{
  config = lib.mkIf config.features.ai.ollama.enable {
    services.ollama = {
      package = unstable.ollama-rocm;
      enable = true;
      acceleration = "rocm";
      host = "0.0.0.0";
      rocmOverrideGfx = "11.0.2";
    };
  };
}
