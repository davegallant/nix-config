{ pkgs, ... }:

{
  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;

  # Automatically optimize the Nix store.
  nix.autoOptimiseStore = true;

  # Enable Nix flake support.
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dave = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  services.tailscale.enable = true;

}
