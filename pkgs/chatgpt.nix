{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
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
    autoPatchelfHook
    dpkg
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib usr/share $out/
    mkdir -p $out/bin
    ln -s ../lib/chatgpt/codex-launcher $out/bin/chatgpt

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
