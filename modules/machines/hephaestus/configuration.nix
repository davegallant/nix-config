{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware.nix];

  hardware.opengl.enable = true;

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "hephaestus";
    interfaces.enp34s0 = {
      useDHCP = true;
    };
    firewall = {
      allowedUDPPorts = [
        41641 # tailscale
      ];
    };
  };

  services = {
    sshd.enable = true;
    tailscale.enable = true;
    xserver.videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
