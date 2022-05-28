{
  config,
  pkgs,
  ...
}: let
in {
  systemd.services.keyleds = {
    description = "Logitech Keyboard animation for Linux — G410, G513, G610, G810, G910, GPro";
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.keyleds}/bin/set-leds.sh";
    };
  };
}
