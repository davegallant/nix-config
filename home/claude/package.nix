{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  autoPatchelfHook,
  bubblewrap,
  procps,
  socat,
  python3,
  just,
}:
let
  version = "2.1.133"; # renovate: datasource=npm depName=@anthropic-ai/claude-code

  assets = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
      hash = "sha512-pfv9LCybrEG5/y5NGEB3vJQs0QNQbDjGDyFgiNzu700Wq6Wrp+WWYOMKG1i0IGWzuOCUEQ/EqX8aQciQJ+1fLA==";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-arm64/-/claude-code-linux-arm64-${version}.tgz";
      hash = "sha512-lTFLbg92Gj3PpD475xsILmAeBT6b50DMOb1jBUuKCkiLpQY3owtVEtwKB1hBkSwyDO8GZqk7BbXkumkWz0DsBg==";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64/-/claude-code-darwin-arm64-${version}.tgz";
      hash = "sha512-GwRvuTEdbk507q9bSsImv7+sriGEkaMeVvIWS/zl/oS+HlyjGx5xIeLB3BlTWoZqdMr2+zCO6YrbogXPHoB55w==";
    };
  };

  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "claude-code: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  # npm tarballs extract into a "package/" subdirectory
  sourceRoot = "package";

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
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
          [
            procps
            python3
            just
          ]
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
