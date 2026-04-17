# home/niri.nix
#
# Niri scrollable-tiling Wayland compositor setup.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    home.packages = with pkgs; [
      blueman
      brightnessctl
      grim
      nautilus
      networkmanagerapplet
      niri-float-sticky
      playerctl
      slurp
      swaybg
      wl-clipboard
      xclip
      xdg-utils
      xwayland-satellite
    ];

    programs.niri.settings = {
      environment = {
        "NIXOS_OZONE_WL" = "1"; # Electron apps use Wayland natively
        "DISPLAY" = ":0"; # XWayland display set by xwayland-satellite
        "GTK_USE_PORTAL" = "1"; # route GTK file dialogs through xdg-desktop-portal
        "XDG_CURRENT_DESKTOP" = "niri"; # portal backend detection
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

      input = {
        keyboard = {
          xkb.layout = "us";
          repeat-delay = 300;
          repeat-rate = 50;
        };
        mouse = {
          left-handed = true;
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
            "nm-applet"
            "--indicator"
          ];
        }
        { argv = [ "blueman-applet" ]; }
        { argv = [ "mako" ]; }
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
            reset-window-height
            switch-focus-between-floating-and-tiling
            switch-preset-column-width
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
          "${mod}+V".action = {
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
          "Print".action.screenshot = { };
          "Ctrl+Print".action.screenshot-screen = { };
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
          "${mod}+R".action = switch-preset-column-width;
          "${mod}+Shift+R".action = reset-window-height;
          "${mod}+F".action = maximize-column;
          "${mod}+Shift+Return".action = fullscreen-window;
          "${mod}+C".action = center-column;

          # ── Floating toggle ─────────────────────────────────────────────
          "${mod}+T".action = toggle-window-floating;
          "${mod}+Shift+T".action = {
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
          "Control+1".action = focus-workspace 1;
          "Control+2".action = focus-workspace 2;
          "Control+3".action = focus-workspace 3;

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

          # ── Media / brightness ──────────────────────────────────────────
          "XF86AudioPlay".action = {
            spawn = [
              "playerctl"
              "play-pause"
            ];
          };
          "XF86AudioNext".action = {
            spawn = [
              "playerctl"
              "next"
            ];
          };
          "XF86AudioPrev".action = {
            spawn = [
              "playerctl"
              "previous"
            ];
          };
          "XF86AudioRaiseVolume".action = {
            spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
          };
          "XF86AudioLowerVolume".action = {
            spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
          };
          "XF86AudioMute".action = {
            spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
          };
          "XF86MonBrightnessUp".action = {
            spawn = [
              "brightnessctl"
              "set"
              "5%+"
            ];
          };
          "XF86MonBrightnessDown".action = {
            spawn = [
              "brightnessctl"
              "set"
              "5%-"
            ];
          };
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
            "network"
            "pulseaudio"
            "tray"
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
            format = "{:%H:%M  %a %b %d}";
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
            on-click = "pavucontrol";
            scroll-step = 5;
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname} ";
            format-disconnected = "Disconnected ⚠";
            tooltip-format = "{ipaddr}/{cidr}";
            on-click = "nm-connection-editor";
          };

          cpu = {
            format = " {usage}%";
            interval = 5;
          };

          memory = {
            format = " {percentage}%";
            interval = 10;
          };

          tray = {
            spacing = 6;
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
          background-color: #1abc9c;
          color: #0d0f18;
        }
        #pulseaudio {
          padding: 0 10px;
          background-color: #1e6799;
          color: #c0caf5;
        }
        #pulseaudio.muted {
          background-color: #3b4261;
          color: #737aa2;
        }
        #network {
          padding: 0 10px;
          background-color: #2d7a4f;
          color: #c0caf5;
        }
        #network.disconnected {
          background-color: #f7768e;
          color: #0d0f18;
        }
        #memory {
          padding: 0 10px;
          background-color: #9d7cd8;
          color: #0d0f18;
        }
        #tray {
          padding: 0 8px;
          background-color: #1e2030;
        }
        #tray > .passive { -gtk-icon-effect: dim; }
        #tray > .needs-attention { -gtk-icon-effect: highlight; }
        #clock {
          padding: 0 12px;
          background-color: #1e2030;
          color: #c0caf5;
          font-weight: bold;
        }
      '';
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
