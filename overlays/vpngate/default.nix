{ lib, fetchFromGitHub, buildGoModule, }:
buildGoModule rec {
  pname = "vpngate";
  version = "v0.3.0";

  vendorHash = "sha256-4JeVXLoiXdZoQM76cHOt5i31ZZGTId0rt8RkMH62/EM=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-P3eQvdUfjpq4a0Q2Hxby4zZ2uTSPjG1oXHxt8cW6fTQ=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [ davegallant ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
