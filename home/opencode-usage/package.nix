{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  xcodegen,
}:
stdenvNoCC.mkDerivation rec {
  pname = "opencode-usage";
  version = "0-unstable-2026-08-07";

  # Built from davegallant's fork, which carries two fixes over upstream:
  # - the curl parser now handles --url-style commands (what current
  #   Chromium browsers' "Copy as cURL" emits; upstream only recognized
  #   the older bare positional URL form)
  # - the menu bar icon is an adaptive ring gauge colored by rolling (5h)
  #   usage, instead of a static logo
  # See https://github.com/davegallant/opencode-usage/tree/fix/curl-url-flag
  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "opencode-usage";
    rev = "38cd8c6a26767169e2592b9cad5ef179654ec19b";
    hash = "sha256-D6ztEJJcKbaV0ds/g0faEQuiUFVrYcygkuV9ncpmW38=";
  };

  nativeBuildInputs = [ xcodegen ];

  # This is a SwiftUI app with no release binaries or Homebrew tap, so it's
  # built from source with the host's Xcode via xcodegen + xcodebuild. That
  # requires the real Xcode.app (not just Command Line Tools) to already be
  # installed on the host, and only works with sandbox = false since
  # xcodebuild must reach system frameworks Nix doesn't provide.
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
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGN_IDENTITY=- \
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
