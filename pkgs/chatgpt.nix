{
  lib,
  stdenv,
  fetchurl,
  asar,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libusb1,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  nspr,
  nss,
  pango,
  systemd,
}:
stdenv.mkDerivation {
  pname = "chatgpt";
  version = "26.814.41407";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.814.41407_amd64.deb";
    hash = "sha256-BT1azpHEihcUau8Cykq7AKKx6U/9FcoBiR/YSoInyoA=";
  };

  nativeBuildInputs = [
    asar
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libusb1
    libxkbcommon
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
  ];

  # The archive includes optional Qt shims and Android/musl Node prebuilds.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libc++_shared.so"
    "libc.musl-x86_64.so.1"
    "libc.so"
    "libdl.so"
    "liblog.so"
    "libm.so"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  patchPhase = ''
    runHook prePatch

    asar extract usr/lib/chatgpt/resources/app.asar app
    # the vite hash in the chunk name changes with every release
    mainChunk=$(find app/.vite/build -maxdepth 1 -name 'main-*.js' | sort | head -n1)
    test -n "$mainChunk"
    substituteInPlace "$mainChunk" \
      --replace-fail 'let i=r===`win32`&&e.computerUse===!0?{...e,computerUseNodeRepl:!0}:e,o=' 'let i=r===`linux`?{...e,inAppBrowserUse:!1,inAppBrowserUseAllowed:!1,inAppBrowserUseHistory:!1,browserPane:!1}:r===`win32`&&e.computerUse===!0?{...e,computerUseNodeRepl:!0}:e,o='
    asar pack app usr/lib/chatgpt/resources/app.asar

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib usr/share $out/

    mkdir -p $out/bin
    makeWrapper $out/lib/chatgpt/codex-launcher $out/bin/chatgpt \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libglvnd ]} \
      --set CHATGPT_PACKAGED_PLUGINS $out/lib/chatgpt/resources/plugins \
      --run 'pluginCache="''${XDG_CACHE_HOME:-''${HOME}/.cache}/chatgpt/bundled-plugins-26.814.41407"; if [ ! -d "$pluginCache" ]; then pluginCacheTmp="$pluginCache.tmp.$$"; mkdir -p "$(dirname "$pluginCache")"; cp -r --no-preserve=mode "$CHATGPT_PACKAGED_PLUGINS" "$pluginCacheTmp"; chmod -R u+rwX "$pluginCacheTmp"; mv "$pluginCacheTmp" "$pluginCache"; fi; pluginTmp="''${CODEX_HOME:-''${HOME}/.codex}/.tmp/bundled-marketplaces"; if [ -d "$pluginTmp" ]; then chmod -R u+rwX "$pluginTmp"; fi; export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH="$pluginCache"'

    runHook postInstall
  '';

  meta = {
    description = "ChatGPT desktop application for Linux";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
