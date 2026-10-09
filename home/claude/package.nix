{
  lib,
  callPackage,
  stdenvNoCC,
  makeBinaryWrapper,
  procps,
  python3,
  just,
  bubblewrap,
  socat,
}:
let
  version = "2.1.295"; # renovate: datasource=npm depName=@anthropic-ai/claude-code

  assets = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
      hash = "sha512-Q31ekN28viVjgfDuZKXUR5vxIBgUYoLGe+cRmjx/f01omqFDMi6IrgmcK5pWMnRbu/cjsTA/zO+bVES5oY3XUg==";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-arm64/-/claude-code-linux-arm64-${version}.tgz";
      hash = "sha512-MU3ReK1kjstDmjEOzhFZaphh2AVUKnPaik6lOV0WLs3/mOM7mE/mqkdcQ/Sv0KwHH5MnOhSkIjCEl0/8tr+vRg==";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64/-/claude-code-darwin-arm64-${version}.tgz";
      hash = "sha512-ZQLmkEpiWd8sxUYRpQr1yZ39DyVBhrl8MUtbxe33E+z4jFPtUy+CrJXmeRRyyM+FEfvGe/2ab+E59GiSKkprRw==";
    };
  };
in
# npm tarballs extract into a "package/" subdirectory
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "claude-code";
  inherit version assets;
  sourceRoot = "package";
  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp claude $out/bin/.claude-unwrapped
    chmod +x $out/bin/.claude-unwrapped
    makeBinaryWrapper $out/bin/.claude-unwrapped $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --set-default ANTHROPIC_MODEL claude-opus-5-5 \
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
    mainProgram = "claude";
  };
}
