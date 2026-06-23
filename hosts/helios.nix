{
  lib,
  ...
}:
{
  networking.hostName = "helios";

  home-manager.users.dave.imports = [
    ../home/retroarch.nix
    ../home/ryujinx.nix
  ];

  home-manager.users.dave.home.file.".homebrew/trust.json" = {
    force = true;
    text = builtins.toJSON {
      trustedtaps = [ "henrygd/beszel" ];
    };
  };

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

  homebrew.taps = lib.mkAfter [
    "henrygd/beszel"
  ];

  homebrew.brews = lib.mkAfter [
    {
      name = "henrygd/beszel/beszel-agent";
      start_service = true;
    }
  ];

  homebrew.casks = lib.mkAfter [
    "blender"
    "discord"
    "heroic"
    "keepassxc"
    "minecraft"
    "mullvad-vpn"
    "retroarch-metal"
    "signal"
    "steam"
    "transmission"
  ];
}
