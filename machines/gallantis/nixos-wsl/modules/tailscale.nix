{
  config,
  lib,
  pkgs,
  ...
}:
with builtins;
with lib; {
  options.wsl.tailscale = with types; {
    enable = mkEnableOption "Tailscale for WSL";
  };

  config = let
    cfg = config.wsl.tailscale;
  in
    mkIf (config.wsl.enable && cfg.enable) {
      environment.systemPackages = with pkgs; [
        tailscale
      ];

      systemd.services.tailscaled = {
        description = "Tailscale WSL";
        script = ''
          ${pkgs.tailscale}/bin/tailscaled
        '';
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "30s";
        };
      };

    };
}
