{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  autoPatchelfHook,
  unzip,
  python3,
  just,
}:
let
  version = "1.14.34"; # renovate: datasource=github-releases depName=anomalyco/opencode

  assets = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-F0ChJ+gOVvbbNUgq56yFVEHI0R9r2/6UkGPkU2CzQCM=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-H7kio1O2BNXf4AIp8f8BsOymPnc2e55+yPXzPdz4fLA=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-di79wkoV7xBaNHRyfRtkAX26UHv2ct+CeHxwsjkznQM=";
    };
  };

  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "opencode: unsupported system ${stdenvNoCC.hostPlatform.system}");

  isDarwin = stdenvNoCC.hostPlatform.isDarwin;
in
stdenvNoCC.mkDerivation {
  pname = "opencode";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ]
  ++ lib.optionals isDarwin [ unzip ];

  dontBuild = true;
  dontStrip = true;

  unpackPhase =
    if isDarwin then
      ''
        unzip $src
      ''
    else
      ''
        tar -xzf $src
      '';

  installPhase = ''
    mkdir -p $out/bin
    cp opencode $out/bin/.opencode-unwrapped
    chmod +x $out/bin/.opencode-unwrapped
    makeBinaryWrapper $out/bin/.opencode-unwrapped $out/bin/opencode \
      --set OPENCODE_AUTO_UPDATE 0 \
      --prefix PATH : ${
        lib.makeBinPath [
          python3
          just
        ]
      }
  '';

  meta = {
    description = "AI coding agent for the terminal";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames assets;
    mainProgram = "opencode";
  };
}
