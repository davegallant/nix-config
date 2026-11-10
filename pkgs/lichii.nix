{
  basePackage,
  fetchFromGitHub,
  fetchzip,
  xxhash,
}:
let
  src = fetchFromGitHub {
    owner = "zortos293";
    repo = "Lichii";
    rev = "3dae119aeac255a9334386cdf10ca707ef96867d";
    hash = "sha256-L9EzKtqzAgRy5Ci8iqbOjmHVZiheNgC/YKag+5srI2E=";
  };
  nxformatSrc = fetchzip {
    url = "https://github.com/fab918/nxformat/releases/download/V1.0.0/nxformat-1.0.0-linux-x64.tar.gz";
    hash = "sha256-C3jREwH4MPBBeC6jDqMtOcuWmF2LE84o8Sko2tzk7v0=";
    stripRoot = false;
  };
in
basePackage.overrideAttrs (old: {
  pname = "lichii";
  version = "nx2-3dae119";
  inherit src;
  patches = [ ];
  inherit (old) qtWrapperArgs;
  postInstall = "";
  postFixup = (old.postFixup or "") + ''
    for program in "$out/bin/lichii" "$out/bin/eden-cli" "$out/bin/eden-room"; do
      wrapProgram "$program" --prefix LD_LIBRARY_PATH : "${nxformatSrc}/lib"
    done
  '';
  buildInputs = old.buildInputs ++ [ xxhash ];
  cmakeFlags = old.cmakeFlags ++ [
    "-DENABLE_WERROR=OFF"
    "-DLICHII_NXFORMAT_ROOT=${nxformatSrc}"
    "-Dxxhash_FORCE_BUNDLED=ON"
    "-Dxxhash_CUSTOM_DIR=${xxhash}/include"
  ];

  meta = old.meta // {
    description = "Experimental Nintendo Switch and Switch 2 emulator with the RADV mesh fallback";
    homepage = "https://github.com/zortos293/Lichii";
    mainProgram = "lichii";
  };
})
