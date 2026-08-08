{
  lib,
  callPackage,
  makeBinaryWrapper,
  stdenvNoCC,
}:
let
  version = "0.147.0"; # renovate: datasource=github-releases depName=openai/codex

  # kratos + helios (aarch64-darwin) and hephaestus (x86_64-linux) are the
  # consumers; other systems are omitted. Release tags carry a "rust-v" prefix
  # and each asset is a single binary named codex-<triple> at the archive
  # root (see home/codex/update-hashes.sh).
  assets = {
    aarch64-darwin = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
      hash = "sha256-dZhLgfkqcbDA9LO1ytgOXFcXfk2Mi0seE9twOyDcQ1g=";
      binary = "codex-aarch64-apple-darwin";
    };
    x86_64-linux = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-Akbi53ODTgfw+1JJ7W660S5FkeYI+Me7l91qlpBUTDY=";
      binary = "codex-x86_64-unknown-linux-musl";
    };
  };
  binary = assets.${stdenvNoCC.hostPlatform.system}.binary;
in
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "codex";
  inherit version assets;
  sourceRoot = ".";
  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${binary} $out/bin/.codex-unwrapped
    chmod +x $out/bin/.codex-unwrapped
    makeBinaryWrapper $out/bin/.codex-unwrapped $out/bin/codex
  '';

  meta = {
    description = "OpenAI Codex agentic coding tool for the terminal";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
  };
}
