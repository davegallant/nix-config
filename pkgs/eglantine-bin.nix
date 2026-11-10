{
  lib,
  callPackage,
  unzip,
}:
let
  version = "daily-20261109";

  assets = {
    aarch64-darwin = {
      url = "https://github.com/Eglantine-Community/Eglantine/releases/download/${version}/eglantine-macos-arm64.zip";
      hash = "sha256-ZceC0zIAY4mmhmsovHvLcXK5mPWD740/zFJToFvn5co=";
    };
  };
in
callPackage ../home/lib/mk-prebuilt-binary.nix {
  pname = "eglantine";
  inherit version assets;
  sourceRoot = "eglantine.app";
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -R . $out/Applications/eglantine.app
  '';

  meta = {
    description = "Experimental Nintendo Switch and Switch 2 emulator";
    homepage = "https://github.com/Eglantine-Community/Eglantine";
    license = lib.licenses.gpl3Plus;
  };
}
