{ config, pkgs, ... }:
let
  netdata = pkgs.netdata;
  netdataConf = ./netdata.conf;
  netdataDir = "/var/lib/netdata";
in
{
  users.extraGroups.netdata.gid = 220008;
  users.extraUsers.netdata = {
    description = "Netdata server user";
    isSystemUser = true;
    name = "netdata";
    uid = 200008;
  };
  systemd.services.netdata = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    preStart = ''
      mkdir -p ${netdataDir}/config
      mkdir -p ${netdataDir}/logs
      cp -r ${netdata}/share/netdata/web ${netdataDir}/web
      chmod -R 700 ${netdataDir}
      chown -R netdata:netdata ${netdataDir}
    '';
    serviceConfig = {
      Type = "forking";
      ExecStart = "${netdata}/bin/netdata -c ${netdataConf} -u netdata";
      Restart = "on-failure";
    };
  };

  services.nginx.httpConfig = ''
    server {
      server_name netdata.thume.net;
      location / {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:19999;
      }
    }
  '';

}
