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
    defaultGateway = {
      address = "192.168.1.2";
      interface = "enp34s0";
    };
    firewall = {
      allowedTCPPorts = [
        25565 # minecraft
        19999 # netdata
      ];
      allowedUDPPorts = [
        41641 # tailscale
      ];
    };
  };

  services.sshd.enable = true;

  services.tailscale.enable = true;

  services.xserver.videoDrivers = ["amdgpu"];

  services.minecraft-server = {
    enable = false;
    eula = true;
    declarative = true;

    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      motd = "NixOS Minecraft server.";
      max-players = 5;
      enable-rcon = true;
      "rcon.password" = "changeme";
      level-seed = "10292992";
    };
  };
}
