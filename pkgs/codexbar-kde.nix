{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "codexbar-kde";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/EvilFreelancer/CodexBar-KDE/releases/download/v0.5.0/org.rpa.codexbar-v0.5.0.plasmoid";
    hash = "sha256-qgOkCSv/jaLmYmZSreXjdTPVpxayhTD4/IDSqsC2JUw=";
  };

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -d $out/share/plasma/plasmoids/org.rpa.codexbar
    unzip -q $src -d $out/share/plasma/plasmoids/org.rpa.codexbar
  '';

  meta = {
    description = "KDE Plasma widget for CodexBar usage limits";
    homepage = "https://github.com/EvilFreelancer/CodexBar-KDE";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
