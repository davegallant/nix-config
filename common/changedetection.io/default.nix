{ config, pkgs, ... }:
let
  changedetectionDir = "/var/lib/changedetection.io/";
in
{
  systemd.services.changedetection = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    preStart = ''
      mkdir -p ${changedetectionDir}/datastore
    '';
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.changedetection.io}/bin/changedetection.py -d ${changedetectionDir}/datastore";
      Restart = "on-failure";
      WorkingDirectory = "${changedetectionDir}";
    };
  };

}
