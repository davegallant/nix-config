{
  lib,
  callPackage,
  fetchurl,
  makeBinaryWrapper,
  stdenvNoCC,
}:
let
  version = "0.160.0"; # renovate: datasource=github-releases depName=openai/codex

  # kratos + helios (aarch64-darwin) and hephaestus (x86_64-linux) are the
  # consumers; other systems are omitted. Release tags carry a "rust-v" prefix
  # and each asset is a single binary named codex-<triple> at the archive
  # root (see home/codex/update-hashes.sh).
  assets = {
    aarch64-darwin = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
      hash = "sha256-B8PHyjdqj3kRFTQvUxON2jfpfPopuBJdBlLZN4SJS10=";
      binary = "codex-aarch64-apple-darwin";
      codeModeHostUrl = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-aarch64-apple-darwin.tar.gz";
      codeModeHostHash = "sha256-3HD7x26dyuWuPVQkgIyOfC314NtKyCfd1PvjOQFarXU=";
      codeModeHostBinary = "codex-code-mode-host-aarch64-apple-darwin";
    };
    x86_64-linux = {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-MGhlQX1O56kneFhSkQpSf0Hh4Vmt05CsWuOsy2fUShM=";
      binary = "codex-x86_64-unknown-linux-musl";
      codeModeHostUrl = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
      codeModeHostHash = "sha256-rGzWKI8OOfRqM+uhz9N3EWUfFPM9vHPWobgutF4DjKw=";
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
