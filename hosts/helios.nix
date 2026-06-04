{
  lib,
  ...
}:
{
  networking.hostName = "helios";

  system.defaults.dock = {
    autohide = true;
    tilesize = 50;
    orientation = "bottom";
    persistent-apps = [
      "/Applications/ghostty.app"
      "/Applications/Brave Browser.app"
      "/Applications/Obsidian.app"
    ];
  };

  homebrew.casks = lib.mkAfter [
    "bitwarden"
    "steam"
  ];
}
