{ stdenv, lib, fetchurl, }:
stdenv.mkDerivation rec {
  pname = "cd-fzf";
  version = "0.0.1";
  executable = ./cd-fzf;
  phases = [ "unpackPhase" ]; # Remove all other phases
  unpackPhase = ''
    mkdir -p $out/bin
    cp ${executable} $out/bin/cd-fzf
  '';
  meta = with lib; {
    description =
      "\n      Fuzzy find change directory";
    platforms = platforms.unix;
  };
}
