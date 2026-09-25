{
  lib,
  callPackage,
  fetchurl,
  makeBinaryWrapper,
  stdenvNoCC,
}:
let
  version = "0.157.0"; # renovate: datasource=github-releases depName=openai/codex

  # kratos + helios (aarch64-darwin) and hephaestus (x86_64-linux) are the
  # consumers; other systems are omitted. Release tags carry a "rust-v" prefix
  # and each asset is a single binary named codex-<triple> at the archive
  # root (see home/codex/update-hashes.sh).
  assets = {
    aarch64-darwin = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
      hash = "sha256-K9ZK8U3t1HeV8va/1dElz3kZmswse6IiFE4IEnERpco=";
      binary = "codex-aarch64-apple-darwin";
      codeModeHostUrl = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-aarch64-apple-darwin.tar.gz";
      codeModeHostHash = "sha256-JiXQI+K24D0rzEN6Pg4IMcJdPHItKFRjio50kh/3m9k=";
      codeModeHostBinary = "codex-code-mode-host-aarch64-apple-darwin";
    };
    x86_64-linux = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-r/RlOag6/4bjxixZK84sUNlTkfnfKJr68DpQwB0UUz0=";
      binary = "codex-x86_64-unknown-linux-musl";
      codeModeHostUrl = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
      codeModeHostHash = "sha256-qSnaqfagvdwAwMnmQC3xF7ElrNlvnVVPbJnDLH5mxgg=";
      codeModeHostBinary = "codex-code-mode-host-x86_64-unknown-linux-musl";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
  inherit (asset) binary codeModeHostBinary;
  codeModeHost = fetchurl {
    url = asset.codeModeHostUrl;
    hash = asset.codeModeHostHash;
  };
in
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "codex";
  inherit version assets;
  sourceRoot = ".";
  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${binary} $out/bin/.codex-unwrapped
    tar -xzf ${codeModeHost}
    cp ${codeModeHostBinary} $out/bin/codex-code-mode-host
    chmod +x $out/bin/.codex-unwrapped $out/bin/codex-code-mode-host
    makeBinaryWrapper $out/bin/.codex-unwrapped $out/bin/codex
  '';

  meta = {
    description = "OpenAI Codex agentic coding tool for the terminal";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
  };
}
