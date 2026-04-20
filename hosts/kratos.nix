{
  inputs,
  lib,
  modulesPath,
  pkgs,
  unstable,
  ...
}:
{

  imports = [
    inputs.niri.nixosModules.niri
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  networking = {
    hostName = "kratos";
  };

  boot = {
    initrd.availableKernelModules = [
      "ehci_pci"
      "xhci_pci"
      "usbhid"
      "sr_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/psf/Home" = {
    device = "Home";
    fsType = "prl_fs";
    options = [ "nofail" ];
  };

  swapDevices = [ ];

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

  fonts.packages = with pkgs; [
    dejavu_fonts
    fira-mono
    font-awesome
    liberation_ttf
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "Noto Sans Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  time.timeZone = "America/Toronto";

  hardware.graphics.enable = true;
  hardware.parallels.enable = true;

  services.libinput.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };

  services.tailscale = {
    enable = true;
    package = unstable.tailscale;
  };

  environment.systemPackages = [ unstable.claude-code ];

  services.opensnitch.enable = true;

  services.sshd.enable = true;
}
