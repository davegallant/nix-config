{
  lib,
  callPackage,
}:
let
  version = "1.4.1"; # renovate: datasource=github-releases depName=timrogers/litra-autotoggle

  assets = {
    aarch64-darwin = {
      url = "https://github.com/timrogers/litra-autotoggle/releases/download/v${version}/litra-autotoggle_v${version}_darwin-aarch64";
      hash = "sha256-0frPGIAzwdVCiXUumgY89zl1RWxhteKCUW0Sv9Odk6I=";
    };
  };
in
callPackage ../lib/mk-prebuilt-binary.nix {
  pname = "litra-autotoggle";
  inherit version assets;
  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/litra-autotoggle
  '';

  meta = {
    description = "Toggle Logitech Litra lights on and off with your webcam";
    homepage = "https://github.com/timrogers/litra-autotoggle";
    license = lib.licenses.mit;
    mainProgram = "litra-autotoggle";
  };
}
