{
  lib,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ./litellm.nix
    ./nixos-gui.nix
    ./opensnitch.nix
  ];

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo -e "\e[36mPackage version diffs:\e[0m"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://davegallant.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 14d";
    };
  };

  documentation.man.generateCaches = false;

  zramSwap.enable = true;

  boot.tmp.useTmpfs = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/Toronto";

  programs.fish.enable = true;
  programs.nix-ld.enable = lib.mkDefault true;

  services.tailscale = {
    enable = true;
    package = unstable.tailscale;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.dave = {
    isNormalUser = true;
    shell = pkgs.fish;
  };
}
