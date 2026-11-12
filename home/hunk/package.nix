{
  lib,
  callPackage,
}:
let
  version = "0.25.0"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-/DMBFRqbNUALAiPXMEHOqF+xiXLW3FyXorvcQn+tKv4=";
      sourceRoot = "hunkdiff-linux-x64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-Kld5CbR4JCvHWYK+MLwsXr+aAET8OKrZSxEat+mpkuA=";
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
