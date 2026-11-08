{
  basePackage,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "zortos293";
    repo = "Lichii";
    rev = "a97287d98c75ddeae1c31b1f5f4279553a3c18c4";
    hash = "sha256-9+93pllDtRekx/Fs3DmLSRUlm+O9tYMYNon+p2jYYZY=";
  };
in
basePackage.overrideAttrs (old: {
  pname = "lichii";
  version = "nx2-a97287d";
  inherit src;
  patches = [ ];
  qtWrapperArgs = [ ];
  postInstall = "";

  meta = old.meta // {
    description = "Experimental Nintendo Switch and Switch 2 emulator with the RADV mesh fallback";
    homepage = "https://github.com/zortos293/Lichii";
    mainProgram = "lichii";
  };
})
