{ pkgs, ... }:
let
  inherit (pkgs) stdenv;
in
{
  programs.firefox = {
    enable = stdenv.isLinux;

    package = pkgs.librewolf;

    profiles = {
      default = {
        id = 0;
        isDefault = true;
        settings = {
          "privacy.resistFingerprinting" = false; # breaks timezone
          "dom.push.connection.enabled" = false;
          "dom.push.enabled" = false;
          "geo.enabled" = false;
          "intl.regional_prefs.use_os_locales" = true;
          "services.sync.prefs.sync.intl.regional._prefs.use_os_locates" = false;
        };
      };
    };
  };
}
