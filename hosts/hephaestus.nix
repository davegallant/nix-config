{
  inputs,
  lib,
  pkgs,
  modulesPath,
  pvectl,
  unstable,
  ...
}:
let
  chatgpt = pkgs.callPackage ../pkgs/chatgpt.nix { };
  codexbarCli = pkgs.callPackage ../pkgs/codexbar-cli.nix { };
  codexbarKde = pkgs.callPackage ../pkgs/codexbar-kde.nix { };
  rfdFyi = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "rfd-fyi";
    rev = "2d37ac263b1abfbcf69f7adb518bd762b8e626ff";
    hash = "sha256-g//QfJlTsS9DEjtxZHVWICDNilDMZvkeDlufqDkwi7k=";
  };
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../litellm
    ../opensnitch.nix
  ];

  home-manager.users.dave.imports = [
    ../home/keepassxc-ssh-agent.nix
    ../home/retroarch.nix
    ../home/ryujinx.nix
  ];

  system.stateVersion = "26.05";

  boot = {
    kernelPackages = pkgs.linuxPackages;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [
      "ahci"
      "ehci_pci"
      "sd_mod"
      "sr_mod"
      "uhci_hcd"
      "usbhid"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/mnt/tank/media" = {
      device = "192.168.1.16:/mnt/tank/media";
      fsType = "nfs";
      options = [
        "_netdev"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=10"
      ];
    };
    "/mnt/tank/backups" = {
      device = "192.168.1.16:/mnt/tank/backups";
      fsType = "nfs";
      options = [
        "_netdev"
        "noauto"
        "x-systemd.automount"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=10"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  # npm-installed tooling runs via nix-ld (nixos.nix)
  environment.systemPackages = with pkgs; [
    # LINE needs a manually-fetched installer added to the store first — see
    # pkgs/line.nix for instructions. Re-add once that's done on hephaestus:
    # (pkgs.callPackage ../pkgs/line.nix { wine = pkgs.wineWow64Packages.base; })
    (retroarch.withCores (
      cores: with cores; [
        mupen64plus
        snes9x
      ]
    ))
    # KDE's own RDP server, for the things Sunshine's video-codec streaming is
    # bad at -- clipboard sync and crisp static text. Shares the same session
    # Sunshine captures, so it is an alternative front door, not a second
    # desktop. nixpkgs has no services.krdp module, so enabling the server and
    # its cert/credentials is done in System Settings > Remote Desktop.
    # Deliberately not opening 3389 in the firewall: tailscale0 is already a
    # trusted interface, so reach it over the tailnet rather than the LAN.
    #
    # Do not let the display mode change while an RDP session is open. krdpserver
    # fixes its ffmpeg filter graph to the resolution present at connect time and
    # cannot renegotiate; a mid-session change makes every frame fail to hwmap and
    # it retries a few hundred times a second, which starves the compositor and
    # freezes the desktop. Ending a Sunshine session does exactly this, because
    # the app profiles below restore 4K on undo. Recover with
    # `systemctl --user kill -s KILL app-org.kde.krdpserver.service` -- SIGTERM
    # does not land, the process wedges inside a GPU call.
    kdePackages.krdp
    keepassxc
    codexbarCli
    codexbarKde
    chatgpt
    discord
    pvectl.packages.${pkgs.stdenv.hostPlatform.system}.default
    trayscale
    unstable.signal-desktop
    vim
  ];

  networking = {
    hostName = "hephaestus";
    hostId = "861d59c4";
    firewall = {
      allowPing = true;
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };
    networkmanager.enable = true;
  };

  # Auto-login so the Plasma session (and Sunshine, which is tied to
  # graphical-session.target) is always up after a reboot with no manual
  # console login.
  services.displayManager.autoLogin = {
    enable = true;
    user = "dave";
  };

  # sddm-autologin's PAM stack never runs a real password check (auth is just
  # pam_permit), so pam_kwallet5 isn't wired in by default and KWallet has no
  # login password to auto-unlock with -- it falls back to prompting on every
  # boot. Enabling it here lets pam_kwallet5 attempt an unlock with whatever
  # (empty) auth token PAM hands it, which only succeeds because the wallet's
  # own password is set to blank (done once, by hand, in System Settings >
  # KDE Wallet -- autologin already grants a full session with zero
  # credentials, so an encrypted-with-blank-password wallet adds nothing).
  security.pam.services.sddm-autologin.kwallet.enable = true;

  # Screen capture on Plasma Wayland is fussy; see the capture= note below for
  # why the backend is pinned. capSysAdmin is what KMS/DRM capture needs and is
  # kept as a fallback lever, though the KWin backend in use does not need it.
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    # Covers LAN (mDNS auto-discovery) and Tailscale. mDNS doesn't cross
    # the tailnet, so pair from off-LAN by adding the host in Moonlight
    # manually via its Tailscale IP/MagicDNS name.
    openFirewall = true;
    # Recurring bug: desktop audio goes silent after (or sometimes during)
    # a Moonlight session, even though nothing was unplugged. Sunshine's
    # audio capture creates a virtual sink named "sink-sunshine-stereo".
    # WirePlumber records whatever sink was most recently in use as the
    # preferred default in ~/.local/state/wireplumber/default-nodes
    # (default.configured.audio.sink=...). When that session ends the
    # virtual sink is destroyed, but WirePlumber doesn't always fall back
    # to a real device -- both onboard ALSA cards (GPU HDMI/DP and
    # motherboard analog) can end up stuck on profile "off", leaving only
    # a silent "Dummy Output" sink (`wpctl status` shows just Dummy Output
    # under Audio > Sinks).
    #
    # Fix: force a real profile back on, e.g. for the motherboard analog
    # card: `wpctl set-profile 45 2` (get device/profile ids from
    # `wpctl status` / `wpctl inspect <id>`). That's usually enough to get
    # WirePlumber to pick a real default sink again.
    #
    # To stop it recurring for the current stale state, remove the leftover
    # preference: `sed -i '/default.configured.audio.sink=sink-sunshine-stereo/d'
    # ~/.local/state/wireplumber/default-nodes`. It comes back after every
    # streaming session, so this isn't a one-time fix -- no permanent fix
    # found yet.
    settings = {
      # Steam's steamwebhelper process grabs port 47990 (Sunshine's
      # default web UI port, offset +1 from the default base of 47989)
      # for its own local IPC, and reclaims it on every Steam relaunch.
      # Move Sunshine's whole port range off the default to avoid the
      # collision instead of relying on start order.
      port = 48989;
      # Capture backend has to be pinned; neither automatic nor KMS works here.
      # Left on automatic, Sunshine picks the XDG portal backend, which wants
      # an interactive "remote desktop" consent grant that a systemd user
      # service can't answer (xdg-desktop-portal-kde logs "No entry for
      # remote-desktop"). Portal init then fails during startup -- observed
      # both as a SIGTRAP core dump inside portal::start_portal_session and
      # as a start that just stops making progress -- so the listeners never
      # bind and Moonlight reports the host as offline.
      #
      # KMS/DRM capture enumerates the monitor list but then dies with
      # "Unable to initialize capture method" / "Platform failed to
      # initialize", most likely because KWin holds DRM master on this
      # qemu-guest VM. Every encoder probe then fails downstream of the
      # missing capture source, so Sunshine serves 503s instead.
      #
      # KWin's native screencasting needs no portal consent and no DRM
      # master, so it is the one path left on Plasma Wayland.
      capture = "kwin";
      # Encoder probing stops at the first family that works and vulkan sits
      # ahead of vaapi in that order, so VA-API is never reached on its own.
      # Vulkan Video encode on RADV is the newest and least tuned path for this
      # AMD GPU, VA-API the mature one -- that, not measured gain, is the reason
      # this is pinned. It was tried as a fix for pointer lag and made no
      # perceptible difference; the jitter turned out to be the client's Wi-Fi.
      encoder = "vaapi";
    };
    applications.apps =
      let
        kscreen-doctor = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor";
      in
      [
        {
          # 4K is DP-1's resting mode, but set it explicitly anyway so this
          # profile recovers the display if another session ended uncleanly
          # and never ran its undo.
          name = "4K";
          prep-cmd = [
            {
              do = "${kscreen-doctor} output.DP-1.mode.3840x2160@60";
              undo = "${kscreen-doctor} output.DP-1.mode.3840x2160@60";
            }
          ];
        }
        {
          # Sized for streaming to the 13" MacBook Air. Its panel is 16:10.4,
          # which DP-1 has no mode for (and the display reports no custom mode
          # support), so 2560x1600 is the closest fit: exact width match, 64px
          # short on height.
          name = "MacBook Air";
          prep-cmd = [
            {
              do = "${kscreen-doctor} output.DP-1.mode.2560x1600@60";
              undo = "${kscreen-doctor} output.DP-1.mode.3840x2160@60";
            }
          ];
        }
      ];
  };

  # Keep Sunshine installed but out of boot; `systemctl start sunshine` when
  # you want it, `systemctl stop sunshine` to end it.
  systemd.services.sunshine.enable = false;

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    gc.dates = "daily";
  };

  users.users.dave.extraGroups = [
    "docker"
    "gamemode"
    "input"
    "libvirtd"
    "networkmanager"
    "plugdev"
    "uinput" # lets Sunshine create virtual gamepads for Moonlight clients
    "wheel"
  ];

  # Let dave's systemd --user instance (tmux-server, etc.) keep running after
  # SSH sessions end and start again on boot, without needing an active login.
  users.manageLingering = true;
  users.users.dave.linger = true;

  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.qmk.enable = true;
  # udev rules for Steam Controller / Xbox / PS / other gamepads
  hardware.steam-hardware.enable = true;

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Hephaestus is a VM that should never sleep/suspend/hibernate
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    IdleAction = "ignore";
  };

  services.resolved.enable = true;

  services.syncthing = {
    enable = true;
    user = "dave";
    dataDir = "/home/dave";
    configDir = "/home/dave/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.urAccepted = -1;
  };

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;

  services.ollama = {
    package = unstable.ollama-rocm;
    enable = true;
    host = "0.0.0.0";
    rocmOverrideGfx = "11.0.2";
    loadModels = [ "qwen2.5:7b-instruct" ];
  };

  # Tags RedFlagDeals deals on rfd.davegallant.ca via the local LiteLLM proxy.
  # Cloudflare Workers can't reach a LAN, so the enricher runs here and
  # pushes results in. gpt-5.4-mini is served by the local litellm service.
  users.users.rfd-enrich = {
    isSystemUser = true;
    group = "rfd-enrich";
  };
  users.groups.rfd-enrich = { };

  # Created independently of the service so the secret file below can be
  # placed before the first `systemctl start`.
  systemd.tmpfiles.rules = [
    "d /var/lib/rfd-enrich 0750 rfd-enrich rfd-enrich -"
  ];

  systemd.services.rfd-enrich = {
    description = "Tag RedFlagDeals deals with the local LiteLLM proxy";
    after = [
      "network-online.target"
      "litellm.service"
    ];
    wants = [ "network-online.target" ];
    environment = {
      RFD_FYI_ORIGIN = "https://rfd.davegallant.ca";
      ENRICH_MODEL = "gpt-5.4-mini";
      ENRICH_BASE_URL = "http://127.0.0.1:4000/v1";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "rfd-enrich";
      Group = "rfd-enrich";
      # REFRESH_SECRET only. Must not come from the Nix store (world-readable);
      # placed by hand: install -m 600 -o rfd-enrich -g rfd-enrich /dev/stdin
      # /var/lib/rfd-enrich/env <<< 'REFRESH_SECRET=...'
      EnvironmentFile = "/var/lib/rfd-enrich/env";
      ExecStart = "${pkgs.nodejs}/bin/node ${rfdFyi}/tools/enricher/enrich.mjs";

      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  # Manually verify rfd-enrich.service tags cleanly via litellm/gpt-5.4-mini
  # after model changes; the timer remains enabled for normal operation.
  systemd.timers.rfd-enrich = {
    description = "Tag RedFlagDeals deals every 15 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
      RandomizedDelaySec = "1min";
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };
}
