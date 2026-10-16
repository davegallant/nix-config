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
  version = "1.3.0"; # renovate: datasource=github-releases depName=badlogic/pi-mono

  assets = {
    x86_64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-x64.tar.gz";
      hash = "sha256-JPW+Motm1No2h2KWmJUBl09Dq4Q0+7V8NcUjo+pQXe0=";
    };
    aarch64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-arm64.tar.gz";
      hash = "sha256-f9LqFPyjkOv59HQ4uq7wfEs9E9t8yORZgxEYORt+pls=";
    };
    aarch64-darwin = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz";
      hash = "sha256-H5rmHN6uBN1oyvGh6KuOybKSBi9syzJS4KnL6TtbFvE=";
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
