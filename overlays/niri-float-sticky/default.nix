{ buildGoModule, fetchFromGitHub }:

buildGoModule {
  pname = "niri-float-sticky";
  version = "unstable-2025-06-13";

  src = fetchFromGitHub {
    owner = "probeldev";
    repo = "niri-float-sticky";
    rev = "9e51b0554c415167f2d9f1e6b05fffaf6df17cc0";
    hash = "sha256-f6CADiQ/gHS7xQ0WSeTIWV4CxydEuxl3VWXsib7iRGE=";
  };

  vendorHash = "sha256-GqbY3qkPjMxyW9RTsN9hkgM3Bda6A8rb2kR4YQW1nFI=";

  meta.mainProgram = "niri-float-sticky";
}
