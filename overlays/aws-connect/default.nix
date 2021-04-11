{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "aws-connect";
  version = "1.0.18";

  src = fetchFromGitHub {
    owner = "rewindio";
    repo = "aws-connect";
    rev = "06218c9078b8a73cd9d51779db3320b9cbda7f4a";
    sha256 = "sha256-Nh/85IyPgUbKSuYSB1vYv8HGuFka231hkmh4Lysswzo=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ./aws-connect $out/bin
  '';

  meta = with lib; {
    description = "Wrapper script around AWS session manager connections";
    homepage = "https://github.com/rewindio/aws-connect";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
