{
  inputs,
  pkgs,
  ...
}:
{

  imports = [
    inputs.niri.nixosModules.niri
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  networking = {
    hostName = "kratos";
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  system = {
    stateVersion = "25.11";
    activationScripts = {
      diff = {
        supportsDryActivation = true;
        text = ''
          if [[ -e /run/current-system ]]; then
            echo -e "\e[36mPackage version diffs:\e[0m"
            ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
          fi
        '';
      };
    };
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };

  users.users.dave = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  time.timeZone = "America/Toronto";

  services.sshd.enable = true;
}
