{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "vpngate";
  version = "v0.1.4";

  vendorSha256 = "sha256-nZ5Ega+P3xPE4p8ehyVC4KBYWF1qUK+y7Slw2cYdq5U=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "sha256-cLoM/DFLSK22KJvCogSHwLVqLXMMF/tT0BF9a1E0cUY=";
  };

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.gpl3;
    maintainers = with maintainers; [davegallant];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
