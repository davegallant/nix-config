{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment = { variables = { LANG = "en_US.UTF-8"; }; };

  networking = { hostName = "zelus"; };

  services.nix-daemon.enable = true;

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixVersions.stable;

  programs.zsh = {
    enable = true;
    # https://github.com/nix-community/home-manager/issues/108#issuecomment-340397178
    enableCompletion = false;
  };

  system.stateVersion = 4;
}
