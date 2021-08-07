{ pkgs, ... }:
{
  systemd = {
    services = {
      opensnitch = {
        description = "Opensnitch Application Firewall Daemon";
        wants = [ "network.target" ];
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.iptables ];
        serviceConfig = {
          Type = "simple";
          PermissionsStartOnly = true;
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /etc/opensnitch/rules";
          ExecStart = "${pkgs.opensnitch}/bin/opensnitchd -rules-path /etc/opensnitch/rules";
          Restart = "always";
          RestartSec = 30;
        };
        enable = true;
      };
    };
  };

}
