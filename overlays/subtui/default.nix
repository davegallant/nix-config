{
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  mpv,
  lib,
  stdenv,
}:

buildGoModule {
  pname = "subtui";
  version = "2.14.1";

  src = fetchFromGitHub {
    owner = "MattiaPun";
    repo = "SubTUI";
    rev = "v2.14.1";
    hash = "sha256-r6uHOz3ffeVtizN+NeFqKTjcvCguuR0LwoUrCEwFziQ=";
  };

  vendorHash = "sha256-ZI6K3EupgqPvE1ixd7VpJ9cvND0rwcrvRcPfbdjjK+U=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [ mpv ];

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/SubTUI $out/bin/subtui-tmp
    mv $out/bin/subtui-tmp $out/bin/subtui
  ''
  + lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/subtui \
      --prefix PATH : "${lib.makeBinPath [ mpv ]}"
  '';

  meta = {
    description = "Lightweight Subsonic TUI music player";
    homepage = "https://github.com/MattiaPun/SubTUI";
    license = lib.licenses.mit;
    mainProgram = "subtui";
    platforms = lib.platforms.unix;
  };
}
