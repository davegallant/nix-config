{ lib, pkgs, unstable, ... }:
{
  imports = [
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
      max-jobs = "auto";
      cores = 0;
    };
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 14d";
    };
  };

  zramSwap.enable = true;

  boot.tmp.useTmpfs = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/Toronto";

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

  programs.fish.enable = true;
  programs.nix-ld.enable = lib.mkDefault true;

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

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

  services.openssh.enable = true;

  users.users.dave = {
    isNormalUser = true;
    shell = pkgs.fish;
  };
}
