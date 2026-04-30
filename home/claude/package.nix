{
  lib,
  stdenv,
  fetchurl,
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

  asset = assets.${stdenv.hostPlatform.system} or (throw "claude-code: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    inherit (asset) url hash;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
    cp claude $out/bin/claude
    chmod +x $out/bin/claude
  '';

  meta = {
    description = "Claude Code CLI";
    homepage = "https://github.com/anthropics/claude-code";
    platforms = builtins.attrNames assets;
    mainProgram = "claude";
  };
}
