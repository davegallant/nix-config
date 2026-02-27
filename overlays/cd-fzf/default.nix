{ stdenv, lib }:
stdenv.mkDerivation {
  pname = "cd-fzf";
  version = "0.0.1";
  src = ./.;
  installPhase = ''
    install -Dm755 cd-fzf $out/bin/cd-fzf
  '';
  meta = {
    description = "Fuzzy find change directory";
    platforms = lib.platforms.unix;
  };
}
