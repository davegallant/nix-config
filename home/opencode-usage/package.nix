{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  xcodegen,
}:
stdenvNoCC.mkDerivation rec {
  pname = "opencode-usage";
  version = "0-unstable-2026-08-09";

  # Built from davegallant's fork, which carries these changes over upstream:
  # - the curl parser now handles --url-style commands (what current
  #   Chromium browsers' "Copy as cURL" emits; upstream only recognized
  #   the older bare positional URL form)
  # - the menu bar icon is a pair of concentric ring gauges (rolling 5h on
  #   the outer ring, weekly on the inner), instead of a static logo
  # - a notification fires when monthly usage crosses 90%
  # See https://github.com/davegallant/opencode-usage/tree/feat/dual-ring-and-alerts
  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "opencode-usage";
    rev = "e1779bc26776efbb4ceae4462925db62200c79de";
    hash = "sha256-wHG/TbjIz0we3jSxfc3pwX+376Bb7iN/zsblP2rnjXg=";
  };

  nativeBuildInputs = [ xcodegen ];

  # This is a SwiftUI app with no release binaries or Homebrew tap, so it's
  # built from source with the host's Xcode via xcodegen + xcodebuild. That
  # requires the real Xcode.app (not just Command Line Tools) to already be
  # installed on the host, and only works with sandbox = false since
  # xcodebuild must reach system frameworks Nix doesn't provide.
  #
  # Signing is ad-hoc but must be a real bundle signature, not the weaker
  # linker-signed one that CODE_SIGNING_ALLOWED=NO leaves behind: that form
  # takes its identifier from the executable name rather than the bundle ID,
  # and UNUserNotificationCenter then refuses to register the app ("Notifications
  # are not allowed for this application"), which kills the usage alerts.
  DEVELOPER_DIR = "/Applications/Xcode.app/Contents/Developer";

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    export USER=$(id -un)
    xcodegen generate

    # /usr/bin takes precedence only for this command: nixpkgs' own xcrun
    # shim (pulled in for the darwin stdenv) shadows the real one and makes
    # xcodebuild fail to find its own tools. Scoping PATH (rather than
    # exporting it) keeps fixupPhase's GNU find working afterwards.
    PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" /usr/bin/xcodebuild \
      -project OpencodeUsage.xcodeproj \
      -scheme OpencodeUsage \
      -configuration Release \
      -derivedDataPath "$TMPDIR/build" \
      CODE_SIGNING_ALLOWED=YES \
      CODE_SIGN_IDENTITY=- \
      CODE_SIGN_STYLE=Manual \
      build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R "$TMPDIR/build/Build/Products/Release/OpenCode Usage.app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Native macOS menu bar app to monitor Opencode Go subscription usage";
    homepage = "https://github.com/wiscaksono/opencode-usage";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
