{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "vpngate";
  version = "v0.1.3";

  vendorSha256 = "sha256-VR5Z8tIeCWfJzkNAB8/opRDYGxX+frX+x5oxvcSBfeY=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-6hjlCfkHA5rPBoQ9npeVZmwsMjIi93RmxVS/uo8bWMo=";
  };

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [davegallant];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
