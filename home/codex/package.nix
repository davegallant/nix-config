{
  lib,
  callPackage,
  makeBinaryWrapper,
}:
let
  version = "0.147.0"; # renovate: datasource=github-releases depName=openai/codex

  # kratos (aarch64-darwin) is the only consumer; other systems are omitted.
  # Release tags carry a "rust-v" prefix (see home/codex/update-hashes.sh).
  assets = {
    aarch64-darwin = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
      hash = "sha256-dZhLgfkqcbDA9LO1ytgOXFcXfk2Mi0seE9twOyDcQ1g=";
    };
  };
in
# the tarball is a single binary named codex-<triple> at the archive root
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "codex";
  inherit version assets;
  sourceRoot = ".";
  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp codex-aarch64-apple-darwin $out/bin/.codex-unwrapped
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
