{
  lib,
  callPackage,
}:
let
  version = "0.17.3"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-bhkuQjZagfIIPxahwXbNGOkqAW8NmBtgY3zQKyzQcG0=";
      sourceRoot = "hunkdiff-linux-x64";
    };
    aarch64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-tbtOIZy9XhPzTDTvjOBs4kZ+L58wN+Jg8Q7LVjpnum0=";
      sourceRoot = "hunkdiff-linux-arm64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-e/b86d/ma1kifCrc+WeBzcpooQlEGCqYcjVK427+NrA=";
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
