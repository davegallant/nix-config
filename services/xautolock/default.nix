{
  config,
  pkgs,
  ...
}: let
in {
  systemd.services.xautolock = {
    description = "Lock the screen automatically after a timeout";
    wantedBy = ["graphical.target"];

    serviceConfig = {
      Type = "simple";
      User = "dave";
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.xautolock}/bin/xautolock -time 1 -detectsleep -locker /home/dave/lock";
    };
  };
}
