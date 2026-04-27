{
  lib,
  pkgs,
  unstable,
  ...
}:
{
  services.opensnitch = {
    enable = true;
    rules = {
      avahi-ipv4 = {
        name = "Allow avahi daemon IPv4";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              operand = "process.path";
              sensitive = false;
              data = "${lib.getBin pkgs.avahi}/bin/avahi-daemon";
            }
            {
              type = "network";
              operand = "dest.network";
              data = "224.0.0.0/24";
            }
          ];
        };
      };
      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
        };
      };
      systemd-resolved = {
        name = "systemd-resolved";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
        };
      };
      localhost = {
        name = "Allow all localhost";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          operand = "dest.ip";
          sensitive = false;
          data = "^(127\\.0\\.0\\.1|::1)$";
          list = [ ];
        };
      };
      nix-update = {
        name = "Allow Nix";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.nix}/bin/nix";
            }
            {
              type = "regexp";
              operand = "dest.host";
              sensitive = false;
              data = "^(([a-z0-9|-]+\\.)*github\\.com|([a-z0-9|-]+\\.)*nixos\\.org)$";
            }
          ];
        };
      };
      tailscaled = {
        name = "Allow tailscaled";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${lib.getBin unstable.tailscale}/bin/tailscaled";
        };
      };
      clamav-freshclam = {
        name = "Allow ClamAV freshclam";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.clamav}/bin/freshclam";
            }
            {
              type = "regexp";
              operand = "dest.host";
              sensitive = false;
              data = "^([a-z0-9|-]+\\.)*clamav\\.net$";
            }
          ];
        };
      };
      ssh-github = {
        name = "Allow SSH to github";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.openssh}/bin/ssh";
            }
            {
              type = "simple";
              operand = "dest.host";
              sensitive = false;
              data = "github.com";
            }
          ];
        };
      };
    };
  };
}
