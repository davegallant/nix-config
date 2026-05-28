{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.14.0"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-f8/R0OAaJGSJRq7b9XHiYlZgHnLTxuz2GmfrY0SWgOg=";
      dir = "hunkdiff-linux-x64";
    };
    aarch64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-Bbq5e7Y524gLgiwgLPJZeHWY49Z5UX52W8u64WVbY+U=";
      dir = "hunkdiff-linux-arm64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-tG9kRvm69mBONw1kz8N3ZONcXKLu1Ja1N+SBfQSSxvk=";
      dir = "hunkdiff-darwin-arm64";
    };
  };

  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "hunk: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "hunk";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = asset.dir;

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp hunk $out/bin/hunk
    chmod +x $out/bin/hunk
  '';

  meta = {
    description = "Review-first terminal diff viewer for agentic coders";
    homepage = "https://github.com/modem-dev/hunk";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames assets;
    mainProgram = "hunk";
  };
}
