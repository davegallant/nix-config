{
  lib,
  callPackage,
}:
let
  version = "0.24.0"; # renovate: datasource=github-releases depName=modem-dev/hunk

  assets = {
    x86_64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-x64.tar.gz";
      hash = "sha256-dlZAKo671RF60k4SvaGvBF/JyFw7QOctv95N6nm2DGk=";
      sourceRoot = "hunkdiff-linux-x64";
    };
    aarch64-linux = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-linux-arm64.tar.gz";
      hash = "sha256-6qup9cDBhNtKhJOsOGsRLujLtVOITEoOXgQTje9eLSk=";
      sourceRoot = "hunkdiff-linux-arm64";
    };
    aarch64-darwin = {
      url = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-darwin-arm64.tar.gz";
      hash = "sha256-+Hbx6G1rqI4SCTfrefY4iXYqKf7ZUSNtbeac4/+WeBk=";
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
