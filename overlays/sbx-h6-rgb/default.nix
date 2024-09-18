{
  lib,
  fetchFromGitHub,
  pkgs,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "sbx-h6-rgb";
  version = "95b4ef9788ef94e557a4d1e815079d5ea8a70943";

  src = fetchFromGitHub {
    owner = "Oscillope";
    repo = "sbx-h6-rgb";
    rev = version;
    sha256 = "sha256-tKKNdzijloBiGBHf5C604824B/BbxBxvCL/ms4orT9M=";
  };

  buildInputs = with pkgs; [ hidapi ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    install -D sbx-h6-ctl $out/bin/sbx-h6-ctl
  '';

  meta = with lib; {
    description = "Creative SoundBlasterX RGB LED setter.";
    license = licenses.gpl3;
    maintainers = with maintainers; [ davegallant ];
    platforms = platforms.linux;
  };

}
