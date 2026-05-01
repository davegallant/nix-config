{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  autoPatchelfHook,
  unzip,
}:
let
  version = "1.14.30"; # renovate: datasource=github-releases depName=anomalyco/opencode

  assets = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-E7LdMsVUn3sDHou2f7jW6Nh6qeB71vABdiCDbx+3zc4=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-yoauIrHbmGZQ6sTjAXU54VVwVpaJ+2cky48zwOTN9mg=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-A2m0XxAL5PAlxog2DbGyj/i+v8gdbLSIziccTkLdFss=";
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
      --set OPENCODE_AUTO_UPDATE 0
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
