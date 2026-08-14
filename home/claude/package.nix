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
  version = "2.1.232"; # renovate: datasource=npm depName=@anthropic-ai/claude-code

  assets = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
      hash = "sha512-nEd0W44UKPPgFeXLjWl9Qikyieowi8BFABdbYtyL1Cq05pw62h312M9ErCLjRj1cvWeMOYY+tg8RL5npjSQNSg==";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-arm64/-/claude-code-linux-arm64-${version}.tgz";
      hash = "sha512-5Aub8i5pjCVlDBP/tIpHwO/8owfNBu2+FP+w0U8Jmy9s6cEhg/HB7Nyp9KyADhN74w6t0TVGvzUdnFXVMANI4Q==";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64/-/claude-code-darwin-arm64-${version}.tgz";
      hash = "sha512-Vdof3qObcEwpj8Rj9srubqXWEJVWp+Zf7G7HVH1jJq2cDfP6eWM3lm6fIpEjDvcMOAEmNtAgmNCUjOJ2YPunfw==";
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
