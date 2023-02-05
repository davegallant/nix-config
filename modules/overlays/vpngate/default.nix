{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "vpngate";
  version = "v0.1.3";

  vendorSha256 = "sha256-UTASkJXaqAqqZP77hSqdPfbY21PhLvR0A779YJ7tku8=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-74ZqxGKuXaTwv/UtRLRqjwxk9vo0V+nvNs/3L6MjlzQ=";
  };

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [davegallant];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
