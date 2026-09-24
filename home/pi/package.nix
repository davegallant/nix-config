{
  lib,
  stdenv,
  callPackage,
  stdenvNoCC,
  makeBinaryWrapper,
  python3,
}:
let
  version = "0.87.1"; # renovate: datasource=github-releases depName=badlogic/pi-mono

  assets = {
    x86_64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-x64.tar.gz";
      hash = "sha256-9V0CZSF1zT8i5tuCI8k++XoIc4KrtR3JzhMPwE3o90Y=";
    };
    aarch64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-arm64.tar.gz";
      hash = "sha256-F3CrH3H2/pDvnG4jMiDY4UINYP+qa1zxN+r4QJrHWQc=";
    };
    aarch64-darwin = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz";
      hash = "sha256-/QQJeV0D+JrV1Xp3LzpFzCM3Pg4kFIzUSgjXgQn2CT4=";
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
