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
  version = "2.1.161"; # renovate: datasource=npm depName=@anthropic-ai/claude-code

  assets = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
      hash = "sha512-z1FO9foikn7IkPqxXBIs6wzJ++R+CS26nDYfjPAX2E9ALjAEc7X4pb1b/SFjR11ts4jtiUkk9f4jPJbqZ/AN8w==";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-arm64/-/claude-code-linux-arm64-${version}.tgz";
      hash = "sha512-rLEzd8/q4UnTLDSAd3eYgog+G0iZ8y6K8yh0gSxf82d7uOkypYaBUkbmFENuHuzIzCIf9Yy/utCJfp6kQFjUow==";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64/-/claude-code-darwin-arm64-${version}.tgz";
      hash = "sha512-afLYRLnbEnpooP9HZ9ecE3aQhMEHclqtGk93pGx3iYNJNFISzK2ScfdPcDaCm2sitbawEeQKXKmj20FGFgAjZA==";
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
