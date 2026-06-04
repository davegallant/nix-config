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
      "/Applications/Signal.app"
      "/Applications/Line.app"
      "/System/Applications/Messages.app"
      "/System/Applications/Phone.app"
    ];
  };

  homebrew.casks = lib.mkAfter [
    "bitwarden"
    "minecraft"
    "mullvad-vpn"
    "signal"
    "steam"
  ];
}
