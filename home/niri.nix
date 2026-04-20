# Niri scrollable-tiling Wayland compositor setup.

{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config =
    let
      externalIpScript = pkgs.writeShellScript "waybar-external-ip" ''
        data=$(${pkgs.curl}/bin/curl -s https://ipinfo.io/json)
        ip=$(echo "$data" | ${pkgs.jq}/bin/jq -r '.ip')
        country=$(echo "$data" | ${pkgs.jq}/bin/jq -r '.country')
        c1=$(printf '%d' "'$(echo "$country" | cut -c1)")
        c2=$(printf '%d' "'$(echo "$country" | cut -c2)")
        f1=$(printf '\U'$(printf '%08x' $((0x1F1E6 + c1 - 65))))
        f2=$(printf '\U'$(printf '%08x' $((0x1F1E6 + c2 - 65))))
        printf '{"text":"%s","tooltip":"%s"}\n' "$f1$f2" "$ip"
      '';
      gpuUsageScript = pkgs.writeShellScriptBin "gpu-usage" ''
        GPU=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
        MEM=$(cat /sys/class/drm/card*/device/mem_info_vram_used 2>/dev/null | head -1)
        [[ -z "$GPU" ]] && exit 0
        MEM_MB=$(( MEM / 1024 / 1024 ))
        printf '{"text":"%s%%","tooltip":"GPU %s%% VRAM %s MiB","percentage":%s}\n' \
        "$GPU" "$GPU" "$MEM_MB" "$GPU"
      '';
      weatherScript = pkgs.writeShellScriptBin "wttr" ''
        for i in 1 2 3 4 5; do
          result=$(${pkgs.curl}/bin/curl -s --max-time 5 "https://wttr.in/42.982,-81.249?format=%c+%t")
          [ -n "$result" ] && echo "$result" | tr -s ' ' && exit 0
          sleep 3
        done
        echo "no network"
      '';
    in
    lib.mkIf pkgs.stdenv.isLinux {
      home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      home.packages =
        with pkgs;
        [
          bandwhich
          blueman
          brightnessctl
          grim
          gnome-calculator
          nautilus
          networkmanagerapplet
          niri-float-sticky
          playerctl
          pwvucontrol
          slurp
          swaybg
          trayscale
          wl-clipboard
          xclip
          xdg-utils
          xwayland-satellite
        ]
        ++ lib.optional stdenv.hostPlatform.isx86_64 pkgs.nvtopPackages.amd;

      home.sessionVariables = {
        GTK_THEME = "adw-gtk3-dark";
      };

      programs.niri.settings = {
        environment = {
          "NIXOS_OZONE_WL" = "1"; # Electron apps use Wayland natively
          "DISPLAY" = ":0"; # XWayland display set by xwayland-satellite
          "GTK_USE_PORTAL" = "1"; # route GTK file dialogs through xdg-desktop-portal
          "XDG_CURRENT_DESKTOP" = "niri"; # portal backend detection
        } // lib.optionalAttrs (osConfig.networking.hostName == "kratos") {
          "LIBGL_ALWAYS_SOFTWARE" = "1"; # Parallels VM lacks OpenGL 3.3
        };

        cursor = {
          theme = "Bibata-Modern-Classic";
          size = 24;
        };

        gestures = {
          hot-corners = {
            enable = false;
          };
        };

        layout = {
          preset-window-heights = [
            { proportion = 0.25; }
            { proportion = 0.5; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];
          preset-column-widths = [
            { proportion = 0.25; }
            { proportion = 0.5; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];
        };

        input = {
          keyboard = {
            xkb.layout = "us";
            repeat-delay = 300;
            repeat-rate = 50;
          };
          mouse = {
            left-handed = lib.mkIf (osConfig.networking.hostName == "hephaestus") true;
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
          warp-mouse-to-focus.enable = false;
        };

        layout = {
          gaps = 8;
          center-focused-column = "never";
          default-column-width = {
            proportion = 0.5;
          };
          focus-ring = {
            enable = true;
            width = 2;
          };
          border = {
            enable = false;
          };
        };

        animations.enable = false;

        spawn-at-startup = [
          {
            argv = [
              "sh"
              "-c"
              "systemctl --user reset-failed waybar.service; true"
            ];
          }
          { argv = [ "xwayland-satellite" ]; }
          {
            argv = [
              "trayscale"
              "--hide-window"
            ];
          }
          {
            argv = [
              "nm-applet"
              "--indicator"
            ];
          }
          { argv = [ "blueman-applet" ]; }
          { argv = [ "mako" ]; }
          { argv = [ "opensnitch-ui" ]; }
          {
            argv = [
              "swaybg"
              "-m"
              "fill"
              "-i"
              "${../wallpaper.png}"
            ];
          }
          { argv = [ "niri-float-sticky" ]; }
          # clipboard history daemons
          {
            argv = [
              "wl-clip-persist"
              "--clipboard"
              "both"
            ];
          }
          # Parallels clipboard bridge: Wayland -> X11 (VM -> macOS)
          {
            argv = [
              "sh"
              "-c"
              "wl-paste --watch xclip -selection clipboard"
            ];
          }
          # Parallels clipboard bridge: X11 -> Wayland (macOS -> VM)
          {
            argv = [
              "sh"
              "-c"
              ''
                prev=""
                while true; do
                  if curr=$(xclip -selection clipboard -o 2>/dev/null); then
                    if [ "$curr" != "$prev" ]; then
                      echo -n "$curr" | wl-copy
                      prev="$curr"
                    fi
                  fi
                  sleep 0.5
                done
              ''
            ];
          }
          {
            argv = [
              "wl-paste"
              "--type"
              "text"
              "--watch"
              "cliphist"
              "store"
            ];
          }
          {
            argv = [
              "wl-paste"
              "--type"
              "image"
              "--watch"
              "cliphist"
              "store"
            ];
          }
        ]
        ++ lib.optionals (osConfig.networking.hostName == "kratos") [
          # prlcc (Parallels clipboard/drag-drop) starts before xwayland-satellite
          # creates :0, so it exits immediately. Re-launch it once the display is ready.
          {
            argv = [
              "sh"
              "-c"
              "until [ -S /tmp/.X11-unix/X0 ]; do sleep 0.5; done; systemctl --user import-environment DISPLAY && systemctl --user restart prlcc.service"
            ];
          }
        ];

        window-rules = [
          # File picker dialogs
          {
            matches = [
              { app-id = "xdg-desktop-portal"; }
              { app-id = "xdg-desktop-portal-gtk"; }
            ];
            open-floating = true;
          }
          {
            matches = [
              { app-id = "pavucontrol"; }
              { app-id = "nm-connection-editor"; }
              { app-id = "blueman-manager"; }
              { app-id = "org.gnome.Calculator"; }
              { title = "About Mozilla Firefox"; }
            ];
            open-floating = true;
            default-column-width = {
              proportion = 0.4;
            };
          }
          {
            matches = [ { app-id = "com.mitchellh.ghostty"; } ];
            open-floating = false;
          }
          {
            matches = [ { app-id = "steam"; } ];
            open-floating = true;
          }
        ];

        binds =
          let
            inherit (config.lib.niri.actions)
              center-column
              close-window
              consume-or-expel-window-left
              consume-or-expel-window-right
              focus-column-left
              focus-column-right
              focus-window-down
              focus-window-up
              focus-workspace
              focus-workspace-down
              focus-workspace-up
              fullscreen-window
              maximize-column
              move-column-left
              move-column-right
              move-window-down
              move-window-up
              power-off-monitors
              quit
              switch-focus-between-floating-and-tiling
              switch-preset-window-height
              switch-preset-window-height-back
              switch-preset-column-width
              switch-preset-column-width-back
              toggle-overview
              toggle-window-floating
              ;
            mod = "Super";
          in
          {
            # ── Launchers / system ──────────────────────────────────────────
            "Ctrl+Super+T".action = {
              spawn = [ "ghostty" ];
            };
            "${mod}+D".action = {
              spawn = [ "fuzzel" ];
            };
            "${mod}+Y".action = {
              spawn = [
                "sh"
                "-c"
                "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
              ];
            };
            "${mod}+L".action = {
              spawn = [ "swaylock" ];
            };
            "${mod}+Shift+E".action = quit;
            "${mod}+Shift+P".action = power-off-monitors;

            # ── Screenshots ─────────────────────────────────────────────────
            "Print".action.screenshot-screen = { };
            "Ctrl+Print".action.screenshot = { };
            "Alt+Print".action.screenshot-window = { };

            # ── Focus movement ──────────────────────────────────────────────
            "${mod}+Left".action = focus-column-left;
            "${mod}+Right".action = focus-column-right;
            "${mod}+Down".action = focus-window-down;
            "${mod}+Up".action = focus-window-up;

            # ── Window movement ─────────────────────────────────────────────
            "${mod}+Shift+Left".action = move-column-left;
            "${mod}+Shift+Right".action = move-column-right;
            "${mod}+Shift+Down".action = move-window-down;
            "${mod}+Shift+Up".action = move-window-up;

            # ── Column sizing ───────────────────────────────────────────────
            "${mod}+H".action = switch-preset-window-height;
            "${mod}+Shift+H".action = switch-preset-window-height-back;
            "${mod}+R".action = switch-preset-column-width;
            "${mod}+Shift+R".action = switch-preset-column-width-back;
            "${mod}+F".action = maximize-column;
            "${mod}+Shift+F".action = fullscreen-window;
            "${mod}+C".action = center-column;

            # ── Floating toggle ─────────────────────────────────────────────
            "Alt+T".action = toggle-window-floating;
            "Alt+Shift+T".action = {
              spawn = [
                "sh"
                "-c"
                ''
                  niri msg action toggle-window-floating &&
                  niri-float-sticky -ipc set_sticky
                ''
              ];
            };
            "${mod}+Shift+V".action = switch-focus-between-floating-and-tiling;

            # ── Consume / expel from column ─────────────────────────────────
            "${mod}+BracketLeft".action = consume-or-expel-window-left;
            "${mod}+BracketRight".action = consume-or-expel-window-right;

            # ── Close ───────────────────────────────────────────────────────
            "${mod}+Q".action = close-window;

            # ── Workspace switching ─────────────────────────────────────────
            "${mod}+1".action = focus-workspace 1;
            "${mod}+2".action = focus-workspace 2;
            "${mod}+3".action = focus-workspace 3;

            # ── Move window to workspace ────────────────────────────────────
            "${mod}+Shift+1".action.move-column-to-workspace = 1;
            "${mod}+Shift+2".action.move-column-to-workspace = 2;
            "${mod}+Shift+3".action.move-column-to-workspace = 3;

            # ── Scroll workspaces ───────────────────────────────────────────
            "${mod}+WheelScrollDown".action = focus-workspace-down;
            "${mod}+WheelScrollUp".action = focus-workspace-up;

            # ── Overview (birds-eye) ────────────────────────────────────────
            "${mod}+O".action = toggle-overview;

            "${mod}+Shift+S".action = {
              spawn = [
                "sh"
                "-c"
                "swaylock -f && systemctl suspend"
              ];
            };

            # ── Media ──────────────────────────────────────────
            "XF86AudioRaiseVolume".action.spawn = [
              "swayosd-client"
              "--output-volume"
              "raise"
            ];
            "XF86AudioLowerVolume".action.spawn = [
              "swayosd-client"
              "--output-volume"
              "lower"
            ];
            "XF86AudioMute".action.spawn = [
              "swayosd-client"
              "--output-volume"
              "mute-toggle"
            ];

            "XF86AudioPlay".action.spawn = [
              "playerctl"
              "play-pause"
            ];
            "XF86AudioStop".action.spawn = [
              "playerctl"
              "stop"
            ];
            "XF86AudioNext".action.spawn = [
              "playerctl"
              "next"
            ];
            "XF86AudioPrev".action.spawn = [
              "playerctl"
              "previous"
            ];

          };

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      };

      programs.waybar = {
        enable = true;
        systemd = {
          enable = true;
          target = "niri.service";
        };

        settings = [
          {
            layer = "top";
            position = "top";
            height = 28;

            modules-left = [
              "niri/workspaces"
              "niri/window"
            ];
            modules-center = [ ];
            modules-right = [
              "cpu"
              "memory"
              "custom/gpu"
              "network"
              "custom/external-ip"
              "pulseaudio"
              "idle_inhibitor"
              "tray"
              "custom/weather"
              "clock"
            ];

            "niri/workspaces" = {
              format = "{index}";
              all-outputs = false;
            };

            "niri/window" = {
              icon = false;
              max-length = 80;
            };

            clock = {
              format = "{:%I:%M %p  %a %b %d}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
            };

            pulseaudio = {
              format = "  {volume}%";
              format-muted = " muted";
              format-icons = {
                default = [
                  ""
                  ""
                  ""
                ];
                headphone = "";
              };
              on-click = "pwvucontrol";
              scroll-step = 5;
            };

            network = {
              format-ethernet = "▲ {bandwidthUpBits} ▼ {bandwidthDownBits}";
              format-disconnected = "Disconnected ⚠";
              tooltip-format = "{ipaddr}/{cidr}";
              on-click = "ghostty -e sudo bandwhich";
              interval = 2;
            };

            cpu = {
              format = " {usage}%";
              interval = 5;
              on-click = "missioncenter";
            };

            memory = {
              format = " {percentage}%";
              interval = 10;
              on-click = "missioncenter";
            };

            tray = {
              spacing = 6;
            };

            idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                activated = "🔒";
                deactivated = "💤";
              };
            };

            "custom/external-ip" = {
              exec = "${externalIpScript}";
              interval = 60;
              format = "{}";
              return-type = "json";
              on-click = "${pkgs.curl}/bin/curl -s https://icanhazip.com | ${pkgs.wl-clipboard}/bin/wl-copy";
            };
            "custom/gpu" = {
              exec = "${gpuUsageScript}/bin/gpu-usage";
              return-type = "json";
              interval = 2;
              format = "󰾲  {percentage}%";
              states = {
                warning = 75;
                critical = 90;
              };
              on-click = "ghostty -e nvtop";
            };
            "custom/weather" = {
              exec = "${weatherScript}/bin/wttr";
              interval = 3600;
              format = "{}";
              on-click = "xdg-open 'https://weather.gc.ca/en/location/index.html?coords=42.982,-81.249'";
            };
          }
        ];

        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 14px;
            min-height: 0;
            border: none;
            border-radius: 0;
          }
          window#waybar {
            background-color: #0d0f18;
            color: #c0caf5;
          }
          #workspaces {
            margin: 0;
            padding: 0;
          }
          #workspaces button {
            padding: 0 8px;
            margin: 0;
            color: #565f89;
            background: transparent;
            border-bottom: 2px solid transparent;
          }
          #workspaces button.active {
            color: #c0caf5;
            background-color: #1e2030;
            border-bottom: 2px solid #7aa2f7;
          }
          #workspaces button.urgent {
            color: #f7768e;
          }
          #window {
            padding: 0 10px;
            color: #a9b1d6;
          }
          #cpu {
            padding: 0 10px;
            background-color: #0d0f18;
            color: #c0caf5;
          }
          #pulseaudio {
            padding: 0 10px;
            background-color: #0d0f18;
            color: #c0caf5;
          }
          #pulseaudio.muted {
            background-color: #3b4261;
            color: #737aa2;
          }
          #network {
            padding: 0 10px;
            background-color: #0d0f18;
            color: #c0caf5;
          }
          #idle-inhibitor {
            padding: 0 10px;
            background-color: #0d0f18;
            color: #c0caf5;
          }
          #network.disconnected {
            background-color: #f7768e;
            color: #0d0f18;
          }
          #memory {
            padding: 0 10px;
            background-color: #0d0f18;
            color: #c0caf5;
          }
          #tray {
            padding: 0 8px;
            background-color: #0d0f18;
          }
          #tray > .passive { -gtk-icon-effect: dim; }
          #tray > .needs-attention { -gtk-icon-effect: highlight; }
          #clock {
            padding: 0 12px;
            background-color: #0d0f18;
            color: #c0caf5;
            font-weight: bold;
          }
        '';
      };

      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
        };
      };

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "JetBrainsMono Nerd Font:size=13";
            terminal = "ghostty -e";
            width = 40;
            lines = 10;
            horizontal-pad = 20;
            vertical-pad = 10;
            inner-pad = 5;
          };
          colors = {
            background = "1a1b26f2";
            text = "c0caf5ff";
            selection = "283457ff";
            selection-text = "7fc8ffff";
            border = "7fc8ffff";
            match = "7fc8ffff";
          };
          border = {
            width = 2;
            radius = 6;
          };
        };
      };

      services.swayosd.enable = true;

      services.mako = {
        enable = true;
        settings = {
          default-timeout = 5000;
          background-color = "#1a1b26ee";
          text-color = "#c0caf5";
          border-color = "#7fc8ff";
          border-radius = 6;
          border-size = 2;
          font = "JetBrainsMono Nerd Font 12";
          max-visible = 5;
          sort = "-time";
          "urgency=high" = {
            border-color = "#f7768e";
            default-timeout = 0;
          };
        };
      };

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 840; # 14 min: lock before suspend
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            timeout = 900; # 15 min: suspend
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            event = "after-resume";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
      };

      programs.swaylock = {
        enable = true;
        settings = {
          color = "1a1b26";
          ring-color = "7fc8ff";
          key-hl-color = "7fc8ff";
          line-color = "1a1b26";
          inside-color = "1a1b2699";
          text-color = "c0caf5";
          indicator-radius = 100;
          indicator-thickness = 7;
          show-failed-attempts = true;
        };
      };
    };
}
