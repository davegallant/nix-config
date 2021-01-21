{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {

  pname = "vpngate";
  version = "v0.0.2";

  vendorSha256 = "1ys2rvrbxgsrvmjdxqgpmxf0m9nlp905gnr2mrf3c7iaxm86wgf8";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "vpngate";
    rev = version;
    sha256 = "0ky3wd04xd4sb2zskrrlbgys2gw88yqhngg3bl0sjy8kr6099vfn";
  };

  meta = with lib; {
    homepage = "https://www.vpngate.net";
    description = "a client for vpngate.net";
    license = licenses.asl20;
    maintainers = with maintainers; [ davegallant ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
