{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "aws-connect";
  version = "1.0.19";

  src = fetchFromGitHub {
    owner = "rewindio";
    repo = "aws-connect";
    rev = "v${version}";
    sha256 = "sha256-xS5eRVjbjK/qzaZhNApwghNqnHGqVGWJ4hvgDu4dfDQ=";
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
