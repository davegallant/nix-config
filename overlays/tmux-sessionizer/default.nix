{ stdenv, lib, fetchurl, }:
stdenv.mkDerivation rec {
  pname = "tmux-sessionizer";
  version = "0.0.0";

  executable = ./tmux-sessionizer;

  phases = [ "unpackPhase" ]; # Remove all other phases

  unpackPhase = ''
    mkdir -p $out/bin
    cp ${executable} $out/bin/tmux-sessionizer
  '';

  meta = with lib; {
    description =
      "\n      Tmux sessionizer adapted from https://sourcegraph.com/github.com/ThePrimeagen/.dotfiles@5cd09f06d6683b91c26822a73b40e3d7fb9af57a/-/blob/bin/.local/bin/tmux-sessionizer";
    platforms = platforms.unix;
  };
}
