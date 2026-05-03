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
  version = "1.14.33"; # renovate: datasource=github-releases depName=anomalyco/opencode

  assets = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-XThT4pyB16E0kVaQYlAJ9XNsqEBwUp5peWz2LhIjLJ4=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-2IZ+d7kB3QTnB/RZ9Es+KPI6bwwtdA8buK9vS2SsGfc=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-86I4ajzNsehzOvdmYAoOLDWgAa2qoNMUKf+BwNzTIYA=";
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
