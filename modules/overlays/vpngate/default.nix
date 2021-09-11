{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {

  pname = "vpngate";
  version = "v0.1.1";

  vendorSha256 = "sha256-EAtZA7epMWEcDMP3F/9Fh06GUze70cidmaE4b/e3Sic=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-+/yICgCbaofLWk7YIzVKjt0rOVycsecLeoppKOEiUoY=";
  };

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [ davegallant ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
