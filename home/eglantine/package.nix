{
  lib,
  callPackage,
  unzip,
}:
let
  version = "daily-20261106";

  assets = {
    aarch64-darwin = {
      url = "https://github.com/Djihads80/Eglantine/releases/download/${version}/eglantine-macos-arm64.zip";
      hash = "sha256-VSx3zoAD92rQdNf6qcBd6rNoU+ZhMmGdEHfvPh5CBEQ=";
    };
  };
in
callPackage ../lib/mk-prebuilt-binary.nix {
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
    homepage = "https://github.com/Djihads80/Eglantine";
    license = lib.licenses.gpl3Plus;
  };
}
