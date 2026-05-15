{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.12.1"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-iIs1YyVwas8aEyufSWMN2En6awmKR8yC4n0o8u+GG8Y=";
      dir = "hunkdiff-linux-x64";
    };
    aarch64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-kxXnTITRp0awtWjfks003wVeAMi5tfKYsbtrlGV4HuI=";
      dir = "hunkdiff-linux-arm64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-PuRNsdUXBQ4JYrgCjdsBB7UdHNAeHUvA3i5fTjs6rp0=";
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
