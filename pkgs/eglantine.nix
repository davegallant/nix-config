{
  boost,
  cmake,
  cpp-jwt,
  cubeb,
  enet,
  fetchFromGitHub,
  fetchzip,
  ffmpeg-headless,
  fmt_11,
  glslang,
  httplib,
  lib,
  libopus,
  libusb1,
  lz4,
  makeWrapper,
  mesa,
  ninja,
  nlohmann_json,
  openssl,
  pkg-config,
  python3,
  qt6,
  sdl3,
  simpleini,
  stdenv,
  spirv-headers,
  spirv-tools,
  sirit,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  vulkan-utility-libraries,
  xbyak,
  zlib,
  zstd,
}:
let
  pname = "eglantine";
  version = "experimental-20261108-df2989c";
  src = fetchFromGitHub {
    owner = "Eglantine-Community";
    repo = "Eglantine";
    rev = "df2989c794cdb6b979e478c5b02ed7f565ebb443";
    hash = "sha256-ngwXYuqdk3y9ynXMRlSjG/7RmER+KE5SsLmq8x8vh0o=";
  };
  nupMetadataFallbackPatch = ./eglantine-nup-metadata-fallback.patch;
  zbicSrc = fetchFromGitHub {
    owner = "kinnay";
    repo = "zbic";
    rev = "11b08f2712264bbed731545085cbd9702096ceb7";
    hash = "sha256-pHvxa1gkUvQo6mUgmLWtj1kcu01BLdGmttZyb8ZAj/o=";
  };
  frozenSrc = fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "frozen";
    rev = "61dce5ae18";
    hash = "sha256-zIczBSRDWjX9hcmYWYkbWY3NAAQwQtKhMTeHlYp4BKk=";
  };
  gamemodeSrc = fetchFromGitHub {
    owner = "FeralInteractive";
    repo = "gamemode";
    rev = "ce6fe122f3";
    hash = "sha256-RMi4PBKqx1kdthKPs8x7GZyvIapo8PXDeMoT4QCxiws=";
  };
  quazipSrc = fetchFromGitHub {
    owner = "stachenov";
    repo = "quazip";
    rev = "2e95c9001b";
    hash = "sha256-F2bPhBNRNcG6qQTlHbEkdTSKEXXTNubIS1+13nBNSU8=";
  };
  tzdbSrc = fetchzip {
    url = "https://git.eden-emu.dev/eden-emu/tzdb_to_nx/releases/download/230326/230326.tar.gz";
    hash = "sha256-d9pC/IcarSjvab+c2kMadCBc+1KkAoe2WG1K9+YtSvo=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  patches = [ nupMetadataFallbackPatch ];

  nativeBuildInputs = [
    cmake
    makeWrapper
    ninja
    pkg-config
    python3
    qt6.wrapQtAppsHook
  ];

  qtWrapperArgs = [
    "--set-default"
    "EDEN_NX2_NO_MESH"
    "1"
  ];

  buildInputs = [
    boost
    cpp-jwt
    cubeb
    enet
    ffmpeg-headless
    fmt_11
    glslang
    httplib
    libopus
    libusb1
    lz4
    mesa
    nlohmann_json
    openssl
    qt6.qt5compat
    qt6.qtbase
    qt6.qtcharts
    qt6.qttools
    qt6.qtwayland
    qt6.qtmultimedia
    qt6.qtwebengine
    sdl3
    simpleini
    spirv-headers
    spirv-tools
    sirit
    vulkan-headers
    vulkan-loader
    vulkan-memory-allocator
    vulkan-utility-libraries
    xbyak
    zlib
    zstd
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCPMUTIL_FORCE_SYSTEM=ON"
    "-Dzstd_FORCE_SYSTEM=ON"
    "-Dzbic_FORCE_BUNDLED=ON"
    "-Dzbic_CUSTOM_DIR=${zbicSrc}"
    "-Dfrozen_FORCE_BUNDLED=ON"
    "-Dfrozen_CUSTOM_DIR=${frozenSrc}"
    "-Dgamemode_FORCE_BUNDLED=ON"
    "-Dgamemode_CUSTOM_DIR=${gamemodeSrc}"
    "-DQuaZip-Qt6_FORCE_BUNDLED=ON"
    "-DQuaZip-Qt6_CUSTOM_DIR=${quazipSrc}"
    "-DENABLE_QT=ON"
    "-DENABLE_QT_TRANSLATION=OFF"
    "-DENABLE_RESHADE=OFF"
    "-DENABLE_UPDATE_CHECKER=OFF"
    "-DUSE_DISCORD_PRESENCE=OFF"
    "-DYUZU_TESTS=OFF"
    "-DYUZU_TZDB_PATH=${tzdbSrc}"
    "-DYUZU_USE_BUNDLED_FFMPEG=OFF"
    "-DYUZU_USE_EXTERNAL_FFMPEG=OFF"
    "-DYUZU_USE_QT_MULTIMEDIA=OFF"
    "-DYUZU_USE_QT_WEB_ENGINE=OFF"
  ];

  postInstall = ''
    install -Dm444 ${src}/dist/dev.eden_emu.eden.svg \
      $out/share/icons/hicolor/scalable/apps/dev.eglantine.eglantine.svg
  '';

  meta = {
    description = "Experimental Nintendo Switch and Switch 2 emulator";
    homepage = "https://github.com/Djihads80/Eglantine";
    license = lib.licenses.gpl3Plus;
    mainProgram = "eglantine";
    platforms = [ "x86_64-linux" ];
  };
}
