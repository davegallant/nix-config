{
  lib,
  stdenv,
  callPackage,
  stdenvNoCC,
  makeBinaryWrapper,
  python3,
}:
let
  version = "0.80.10"; # renovate: datasource=github-releases depName=badlogic/pi-mono

  assets = {
    x86_64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-x64.tar.gz";
      hash = "sha256-q2YE9sPz0FB4Pnq7vdH3m3dbIPOWmDPOlyF0BoXQHhM=";
    };
    aarch64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-arm64.tar.gz";
      hash = "sha256-3+Q0AGPf4nQG+mSqyZ2QRyb6wHkZfEV5uegVUXXQUnI=";
    };
    aarch64-darwin = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz";
      hash = "sha256-RAbtInxIby48Fs8U95PcOtRrXQG/aRNaJCTP+lipo0s=";
    };
  };
in
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "pi";
  inherit version assets;
  sourceRoot = "pi";
  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isElf [ stdenv.cc.cc.lib ];

  installPhase = ''
    mkdir -p $out/lib/pi $out/bin
    cp -r . $out/lib/pi/
    chmod +x $out/lib/pi/pi
    makeBinaryWrapper $out/lib/pi/pi $out/bin/pi \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';

  meta = {
    description = "A minimal terminal coding harness";
    homepage = "https://pi.dev";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
}
