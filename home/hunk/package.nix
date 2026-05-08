{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.10.0"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-5J8zYH4WTHIG7JVA2Sq1wd3Q4q/cE7eWCzAQFOvUbaM=";
      dir = "hunkdiff-linux-x64";
    };
    aarch64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-epaG0urTx3nqr2mIClkDLzrxf+gOZE4EDyC0YyEPq8M=";
      dir = "hunkdiff-linux-arm64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-X+dCe6J4FF+5zhIGOuxIi+vdfn7QXtSjbK9um/BR1Ag=";
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
