{
  lib,
  callPackage,
}:
let
  version = "0.24.1"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-S4yY+Nl3RUmZFsweHS8n/9JYxtY1jdRTL2HkHF6xlpI=";
      sourceRoot = "hunkdiff-linux-x64";
    };
    aarch64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-q0nIq6gsPJhy8cXu/ZbRxMJJHluAZH+XsugfxsRnbes=";
      sourceRoot = "hunkdiff-linux-arm64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-X5r9Qdgl4vh5WLBwLneeUtOCB8C0LVMW7+VCGPNbTX0=";
      sourceRoot = "hunkdiff-darwin-arm64";
    };
  };
in
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "hunk";
  inherit version assets;
  sourceRoot = asset: asset.sourceRoot;

  installPhase = ''
    mkdir -p $out/bin
    cp hunk $out/bin/hunk
    chmod +x $out/bin/hunk
  '';

  meta = {
    description = "Review-first terminal diff viewer for agentic coders";
    homepage = "https://github.com/modem-dev/hunk";
    license = lib.licenses.mit;
    mainProgram = "hunk";
  };
}
