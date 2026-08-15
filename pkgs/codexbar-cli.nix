{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  curl,
  sqlite,
}:
stdenv.mkDerivation {
  pname = "codexbar";
  version = "0.49.6";

  src = fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v0.49.6/CodexBarCLI-v0.49.6-linux-x86_64.tar.gz";
    hash = "sha256-BI7/YHzUmAm/AyQpYQN4liif/9v0vp/kbpW0LsQxSrc=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    curl
    sqlite
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    install -Dm755 CodexBarCLI $out/bin/CodexBarCLI
    install -Dm644 VERSION $out/bin/VERSION
    cp -r CodexBar_CodexBarCore.bundle $out/bin/
    ln -s CodexBarCLI $out/bin/codexbar
  '';

  meta = {
    description = "CLI for checking AI coding-provider usage limits";
    homepage = "https://github.com/steipete/CodexBar";
    license = lib.licenses.mit;
    mainProgram = "codexbar";
    platforms = [ "x86_64-linux" ];
  };
}
