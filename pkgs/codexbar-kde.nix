{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "codexbar-kde";
  version = "0.5.0-unstable-2026-08-17";

  src = fetchurl {
    url = "https://codeload.github.com/davegallant/CodexBar-KDE/tar.gz/a97ead0f68fa8c33d364907a528157a60ae3e5da";
    hash = "sha256-vPX1JP6eCtzdOJRnlzLAFgExhYF4fkYC7YQoLrR8r7c=";
  };
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -d $out/share/plasma/plasmoids/org.rpa.codexbar
    tar -xzf $src -C $out/share/plasma/plasmoids/org.rpa.codexbar \
      --strip-components=2 --wildcards --no-anchored 'package/*'
  '';

  meta = {
    description = "KDE Plasma widget for CodexBar usage limits";
    homepage = "https://github.com/EvilFreelancer/CodexBar-KDE";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
