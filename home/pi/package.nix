{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  autoPatchelfHook,
  python3,
}:
let
  version = "0.78.0"; # renovate: datasource=github-releases depName=badlogic/pi-mono

  assets = {
    x86_64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-x64.tar.gz";
      hash = "sha256-isAzQ9HhIoEG6BchV/Mta4goKeRrNP6vV38XGl8Th8w=";
    };
    aarch64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-arm64.tar.gz";
      hash = "sha256-SRVRc2gkc3INnez03uy+11T66Ekl7wA8C2aqwx1fkAU=";
    };
    aarch64-darwin = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz";
      hash = "sha256-aOu+T1ahNqHHus4zk+ykrQqh/Z8lO3l/03AFi9Of4HA=";
    };
  };

  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "pi: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "pi";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = "pi";

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isElf [ stdenv.cc.cc.lib ];

  dontBuild = true;
  dontStrip = true;

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
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames assets;
    mainProgram = "pi";
  };
}
