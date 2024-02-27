{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "vpngate";
  version = "v0.1.5";

  vendorHash = "sha256-TQLHvoVAMvDtm/9EQUaNVVjQajyMBnJu8NF6Kt0+RJ8=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-+KZ6/h8JLEisnIja4lstJYVHzEC/8PdHL3czK/mJCAs=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [davegallant];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
