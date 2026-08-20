{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "unity-cli";
  version = "1.0.0-beta.5";

  src = fetchurl {
    url = "https://public-cdn.cloud.unity3d.com/hub/prod/cli/1.0.0-beta.5/unity-linux-x64";
    hash = "sha256-f7Dtvi5siJ04sJgsAwcThV7cqCw82gF1iwvVCj/9NWo=";
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 unity-linux-x64 $out/bin/unity
  '';

  meta = {
    description = "Command-line interface for Unity";
    homepage = "https://docs.unity.com/en-us/unity-cli";
    license = lib.licenses.unfree;
    mainProgram = "unity";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = lib.sourceTypes.binaryNativeCode;
  };
}
