{pkgs, ...}: {
  services.tailscale.enable = true;

  networking = {
    firewall = {
      allowPing = false;
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
    };
  };
}
