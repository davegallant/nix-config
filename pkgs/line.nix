{
  lib,
  fetchurl,
  requireFile,
  makeDesktopItem,
  writeShellApplication,
  symlinkJoin,
  wine,
  winetricks,
  coreutils,
}:
let
  pname = "line";
  version = "9.2.0.3431";

  # On HiDPI, LINE renders tiny: it ignores both Wine's LogPixels registry
  # DPI and Qt's QT_SCALE_FACTOR env var (tried both, no effect - likely
  # because it renders via Skia, see skottie.dll). Fix is on the KDE side,
  # not here: System Settings > Display Configuration > Legacy applications
  # (X11) > "Scaled by the system" (default is "Apply scaling themselves").

  # LINE has no native Linux build, so this runs the official Windows
  # installer under Wine. Structure and DLL overrides are based on
  # https://github.com/emmanuelrosa/erosanix/blob/master/pkgs/line.nix
  # (MIT), reimplemented here as a single persistent Wine prefix instead
  # of depending on erosanix's mkWindowsApp framework.
  #
  # LINE's current official installer (desktop.line-scdn.net/win/new/LineInst.exe)
  # is an MSI-based network bootstrapper that fails partway through
  # Wine's incomplete setupapi file-copy support (do_file_copyW
  # "Unsupported style"), silently producing no LineLauncher.exe.
  # The last full offline NSIS installer (9.2.0 build 3431) is the one
  # confirmed to work under Wine, but it's no longer hosted by LINE
  # directly, only mirrored (with a signed, expiring URL) on uptodown's
  # "older versions" archive. requireFile avoids baking in a URL that
  # will inevitably 410 again; verify against davegallant.cachix.org
  # (configured as a substituter in nixos.nix) before re-fetching by hand.
  installer = requireFile {
    name = "line-9-2-0-build-3431.exe";
    sha256 = "469421829b4eda17af44236f1a684fe970899324677f741f22033a2218b40bf5";
    message = ''
      LINE's installer can't be fetched automatically: LINE's own CDN now
      serves an installer format that doesn't work under Wine, and the
      last working version (9.2.0 build 3431) is only available via
      uptodown's signed, expiring download links.

      1. Go to https://line.en.uptodown.com/windows/versions
      2. Download version 9.2.0, build 3431
      3. Add it to the Nix store:
           nix-store --add-fixed sha256 ./line-9-2-0-build-3431.exe
    '';
  };

  icon = fetchurl {
    url = "https://line.me/favicon-32x32.png";
    sha256 = "1kry4kab23d8knz1yggj3a0mdz56n7zf6g5hq4sbymdm103j4ksh";
  };

  launcher = writeShellApplication {
    name = pname;
    runtimeInputs = [
      wine
      winetricks
      coreutils
    ];
    text = ''
      export WINEARCH=win64
      export WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/line/wineprefix"

      app_launcher="$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/bin/LineLauncher.exe"

      if [ ! -f "$app_launcher" ]; then
        mkdir -p "$WINEPREFIX"

        # Disable the Mono/Gecko prompts on first prefix boot.
        WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree=d;mshtml=d" wine boot --init
        wineserver -w

        # Required: LINE's installer expects to see Windows 10.
        winetricks -q win10

        # LINE's installer bundles an MSI-based prerequisite (WebView2)
        # that reliably fails on the first pass under Wine's incomplete
        # setupapi file-copy support, but succeeds on a second pass
        # against the same prefix. Retry once rather than chase the
        # underlying Wine MSI gap.
        for _ in 1 2; do
          WINEDLLOVERRIDES="winemenubuilder.exe=d" wine "${installer}" /S || true
          wineserver -w
          [ -f "$app_launcher" ] && break
        done

        mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/Data"
      fi

      WINEDLLOVERRIDES="winemenubuilder.exe=d" wine start /unix "$app_launcher"
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "LINE";
    categories = [
      "Network"
      "Chat"
    ];
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    launcher
    desktopItem
  ];

  postBuild = ''
    mkdir -p $out/share/icons/hicolor/32x32/apps
    cp ${icon} $out/share/icons/hicolor/32x32/apps/${pname}.png
  '';

  meta = with lib; {
    homepage = "https://line.me";
    description = "LINE messenger desktop client, run via Wine (installed on first launch)";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
