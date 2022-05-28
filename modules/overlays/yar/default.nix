{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "yar";
  version = "master";

  vendorSha256 = "sha256-bBaAP9HQ1fG6gPtoYg9HXnv53DueAFnT4OHE4rwlxvA=";

  src = fetchFromGitHub {
    owner = "nielsing";
    repo = "yar";
    rev = version;
    sha256 = "sha256-f7pTS5Ur8ImbIkPkyunyQEgpeF79CIQFEodg69VxA9I=";
  };

  meta = with lib; {
    description = "Yar is a tool for plunderin' organizations, users and/or repositories.";
    license = licenses.gpl3;
    maintainers = with maintainers; [davegallant];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
