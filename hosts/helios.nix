{
  lib,
  username,
  ...
}:
let
  trustedHomebrewTaps = [
    "davegallant/public"
    "henrygd/beszel"
  ];
in
{
  networking.hostName = "helios";

  home-manager.users.dave.imports = [
    ../home/retroarch.nix
    ../home/ryujinx.nix
  ];

  system.activationScripts.preActivation.text = ''
    homebrew_trust_dir=/Users/${lib.escapeShellArg username}/.homebrew
    homebrew_trust_file="$homebrew_trust_dir/trust.json"

    if [ -L "$homebrew_trust_dir" ]; then
      rm "$homebrew_trust_dir"
    fi

    mkdir -p "$homebrew_trust_dir"
    if [ -L "$homebrew_trust_file" ]; then
      rm "$homebrew_trust_file"
    fi

    cat > "$homebrew_trust_file" <<'EOF'
    ${builtins.toJSON { trustedtaps = trustedHomebrewTaps; }}
    EOF
    chown -R ${lib.escapeShellArg username}:staff "$homebrew_trust_dir"
    chmod 700 "$homebrew_trust_dir"
    chmod 600 "$homebrew_trust_file"
  '';

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

  homebrew.taps = lib.mkAfter trustedHomebrewTaps;

  homebrew.brews = lib.mkAfter [
    "davegallant/public/vpngate"
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
