{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "vpngate";
  version = "v0.2.0";

  vendorHash = "sha256-C91UAAQuS79W93s/0gqk5JBlYSPsxEHw9EAKJxWxyGI=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-IRh1ehxrzBuxduGC8sud/euVlrKM3aZT8DW64Xxr4cU=";
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
