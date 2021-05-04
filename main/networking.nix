{ pkgs, ... }:

{
  services.tailscale.enable = true;

  networking.firewall = {
    allowPing = false;
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
  };
}
