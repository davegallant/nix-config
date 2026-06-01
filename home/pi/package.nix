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
      hash = "sha256-51AxzavGkLQ/TRNP2qak1pMDjRoTss+nBcTHBt/vgcU=";
    };
    aarch64-linux = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-arm64.tar.gz";
      hash = "sha256-2NFF2JqV1JGTaTMrMAmVFHPar6U4x7b/odyuEGvw4+k=";
    };
    aarch64-darwin = {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz";
      hash = "sha256-BZF64fvEchD9JhQwqSRqN+nGDXwIUoKY9er3t74Ky0w=";
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
