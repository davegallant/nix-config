{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {

  pname = "vpngate";
  version = "v0.1.0";

  vendorSha256 = "sha256-HOGPzCMh7nVKfpzKkAyaSDeRyowj9VuizCA7CLFWp78=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-kToXqICQHWgXVLc3fN2bAxHAQWS3Dq3jdpi3CBXkP90=";
  };

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [ davegallant ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
