{
  pkgs,
  lib,
  hostname,
  ...
}:
{
  config = lib.mkIf (hostname == "hephaestus") {
    programs.borgmatic = {
      enable = true;
      backups = {
        hephaestus = {
          location = {
            sourceDirectories = [ "/home/dave" ];
            repositories = [
              {
                path = "/mnt/tank/backups/hephaestus";
                label = "tank";
              }
            ];
            extraConfig = {
              exclude_caches = true;
              umask = 0022;
              exclude_patterns = [
                "/home/dave/.cache"
                "/home/dave/.local/share/Steam"
                "/home/dave/.local/share/Trash"
                "/home/dave/.local/share/containers"
                "/home/dave/.local/share/flatpak"
                "/home/dave/.var"
                "/home/dave/Games"
                "/home/dave/libvirt"
              ];
            };
          };
          retention = {
            keepDaily = 7;
            keepWeekly = 4;
            keepMonthly = 6;
          };
          hooks.extraConfig = {
            commands = [
              {
                after = "repository";
                when = [ "create" ];
                states = [ "finish" ];
                run = [
                  "notify-send 'Borgmatic' 'Backup completed successfully'"
                ];
              }
              {
                after = "repository";
                when = [ "create" ];
                states = [ "fail" ];
                run = [
                  "notify-send -u critical 'Borgmatic' 'Backup FAILED'"
                ];
              }
            ];
          };
        };
      };
    };

    systemd.user.services.borgmatic = {
      Unit.Description = "borgmatic backup";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.borgmatic}/bin/borgmatic --verbosity -1";
      };
    };

    systemd.user.timers.borgmatic = {
      Unit.Description = "borgmatic backup timer";
      Timer = {
        OnCalendar = "20:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
