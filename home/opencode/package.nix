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
  version = "1.14.45"; # renovate: datasource=github-releases depName=anomalyco/opencode

  assets = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-7gZuM5HJRjBHLQTuPUHJGV1xC4YZy+uUdtur+GF4P14=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-XiVQLyxKw8kf1iIh3FnXg3Chp+dRWNcERohtQr/5jBk=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-e0t3S8Keq2jmc//FV4ZI11fNXzEwuP6uMk8UkPSB36w=";
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
