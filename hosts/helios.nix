{
  lib,
  pkgs,
  pvectl,
  unstable,
  username,
  ...
}:
let
  trustedHomebrewTaps = [
    "davegallant/public"
  ];
  homebrewTrust = pkgs.writeText "homebrew-trust.json" (
    builtins.toJSON { trustedtaps = trustedHomebrewTaps; }
  );
in
{
  networking.hostName = "helios";

  environment.systemPackages = [
    (pkgs.callPackage ../pkgs/eglantine-bin.nix { })
    unstable.argocd
    unstable.talosctl
    pvectl.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home-manager.users.${username}.imports = [
    ../home/retroarch.nix
    ../home/ryujinx.nix
  ];

  # Runs as the user, not root: the directory is user-writable, so a root
  # write or chown there could be redirected through a planted symlink.
  system.activationScripts.preActivation.text = ''
    homebrew_trust_dir=/Users/${lib.escapeShellArg username}/.homebrew
    homebrew_trust_file="$homebrew_trust_dir/trust.json"
    as_user() { /usr/bin/sudo --user=${lib.escapeShellArg username} -- "$@"; }

    if [ -L "$homebrew_trust_dir" ]; then
      as_user /bin/rm "$homebrew_trust_dir"
    fi
    as_user /bin/mkdir -p "$homebrew_trust_dir"
    as_user /bin/chmod 700 "$homebrew_trust_dir"
    as_user /bin/rm -f "$homebrew_trust_file"
    as_user /usr/bin/install -m 600 ${homebrewTrust} "$homebrew_trust_file"
  '';

  system.defaults.dock = {
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
  ];

  homebrew.casks = lib.mkAfter [
    "blender"
    "heroic"
    "keepassxc"
    "librewolf"
    "prismlauncher"
    "moonlight"
    "retroarch-metal"
    "signal"
    "steam"
    "transmission"
    "zoom"
  ];
}
