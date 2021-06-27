{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "srv";
  version = "v0.1.2";

  vendorSha256 = "sha256-ebumpo9hgr7A+Fsznga4ksYu4mcOIfaaKz0uJu2rivE=";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "srv";
    rev = version;
    sha256 = "sha256-x5l/NFEbbRPMBY061g4qRHYV6QUShO7yHqSw+Hir9M0=";
  };

  meta = with lib; {
    description = "a simple rss viewer";
    license = licenses.gpl3;
    maintainers = with maintainers; [ davegallant ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
