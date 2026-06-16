{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) stdenv;

  enableSyncthingAgent = stdenv.isDarwin;

  romRoot = "${config.home.homeDirectory}/Games/ROMs";
  saveRoot = "${config.home.homeDirectory}/Sync/RetroArch/saves";
  stateRoot = "${config.home.homeDirectory}/Games/RetroArch/states";
  configPath =
    if stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/RetroArch/config/retroarch.cfg"
    else
      "${config.home.homeDirectory}/.config/retroarch/retroarch.cfg";
in
{
  home.packages = lib.optionals enableSyncthingAgent [
    pkgs.syncthing
  ];

  home.file."Sync/RetroArch/saves/.stignore" = {
    text = ''
      // keep this folder scoped to normal in-game saves, not ROMs or save states
      .DS_Store
      .Spotlight-V100
      .Trashes
      .fseventsd
      *~
      *.tmp
      *.part
      *.swp
    '';
  };

  launchd.agents.syncthing = lib.mkIf enableSyncthingAgent {
    enable = true;
    config = {
      Label = "org.nix-community.home.syncthing";
      ProgramArguments = [
        "${pkgs.syncthing}/bin/syncthing"
        "--no-browser"
        "--no-restart"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/syncthing.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/syncthing.log";
    };
  };

  home.activation.retroarchSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu

    mkdir -p \
      "${romRoot}/SNES" \
      "${romRoot}/N64" \
      "${saveRoot}" \
      "${stateRoot}" \
      "$(dirname "${configPath}")"

    touch "${configPath}"

    set_retroarch_cfg() {
      key="$1"
      value="$2"
      tmp="$(mktemp)"

      if ${pkgs.gnugrep}/bin/grep -q "^$key =" "${configPath}"; then
        ${pkgs.gawk}/bin/awk -v key="$key" -v value="$value" '
          index($0, key " =") == 1 { $0 = key " = \"" value "\"" }
          { print }
        ' "${configPath}" > "$tmp"
        mv "$tmp" "${configPath}"
      else
        rm -f "$tmp"
        printf '%s = "%s"\n' "$key" "$value" >> "${configPath}"
      fi
    }

    set_retroarch_cfg savefile_directory "${saveRoot}"
    set_retroarch_cfg savestate_directory "${stateRoot}"
    set_retroarch_cfg rgui_browser_directory "${romRoot}"
    set_retroarch_cfg cheevos_enable true
    set_retroarch_cfg cheevos_hardcore_mode_enable false
    set_retroarch_cfg cheevos_leaderboards_enable true
    set_retroarch_cfg cheevos_richpresence_enable true
    set_retroarch_cfg config_save_on_exit true
  '';
}
