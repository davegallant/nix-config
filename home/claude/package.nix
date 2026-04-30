{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  autoPatchelfHook,
  bubblewrap,
  procps,
  socat,
}:
let
  version = "2.1.123"; # renovate: datasource=github-releases depName=anthropics/claude-code

  assets = {
    x86_64-linux = {
      url = "https://github.com/anthropics/claude-code/releases/download/v${version}/claude-linux-x64.tar.gz";
      hash = "sha256-0RNfKwZrSwmnf++ur8U3cxBhr3rzFfKR+AkOV/x0idA=";
    };
    aarch64-linux = {
      url = "https://github.com/anthropics/claude-code/releases/download/v${version}/claude-linux-arm64.tar.gz";
      hash = "sha256-dDxcijHvWKa3aRbOgnmmX3oSldJ5ZWvWDtQDi7b19HY=";
    };
    aarch64-darwin = {
      url = "https://github.com/anthropics/claude-code/releases/download/v${version}/claude-darwin-arm64.tar.gz";
      hash = "sha256-wEwqXioJbZ9lU0elXhOjPaegvyJHIPh+tdwG3cQca98=";
    };
  };

  asset = assets.${stdenvNoCC.hostPlatform.system} or (throw "claude-code: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";

  nativeBuildInputs =
    [ makeBinaryWrapper ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp claude $out/bin/.claude-unwrapped
    chmod +x $out/bin/.claude-unwrapped
    makeBinaryWrapper $out/bin/.claude-unwrapped $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --unset DEV \
      --prefix PATH : ${
        lib.makeBinPath (
          [ procps ]
          ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
            bubblewrap
            socat
          ]
        )
      }
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames assets;
    mainProgram = "claude";
  };
}
