{
  lib,
  pkgs,
  stdenv,
  callPackage,
  stdenvNoCC,
  makeBinaryWrapper,
  python3,
}:
let
  version = "1.6.1";

  assets = {
    x86_64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-x64.tar.gz";
      hash = "sha256-PH8AcV61EuFlwNqMrTFNc8g7VNW/d0i+Stxhj8g1e2g=";
    };
    aarch64-darwin = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz";
      hash = "sha256-2P2OJMKlBUrjg9g7Jvbrb5UO32E5F+Q0pSOU9EzU2TM=";
    };
  };
in
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "pi";
  inherit version assets;
  sourceRoot = "pi";
  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isElf [
    stdenv.cc.cc.lib
    pkgs.libxcb
  ];

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
