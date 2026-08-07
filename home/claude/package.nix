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
  version = "2.1.224"; # renovate: datasource=npm depName=@anthropic-ai/claude-code

  assets = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
      hash = "sha512-3CGFCnI0gpgsqNeJruFALBDGJaKXOuok3alQEg56ty2yOPpIrOx/r2Y0+T4uhJl7kP5Hzw4IFkxo4DZKWvzQ7Q==";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-arm64/-/claude-code-linux-arm64-${version}.tgz";
      hash = "sha512-VHFI8mKruIntKn7eq81sbyS19/KWmQcmJQsS/C+j9M/E+w0s4UytgsL7DADPjBE/GByNiKoRtLYDMntCjRlOdA==";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64/-/claude-code-darwin-arm64-${version}.tgz";
      hash = "sha512-rmtd41Bf+n+YnhjSjtQ8WG5qy8KKogUp3YRfQrkLsTgPUD0H3j869rBInBJT3SHrKQ0hLghQLGM73CC1C+USLQ==";
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
