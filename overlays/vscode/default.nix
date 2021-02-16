{ stdenv, lib, callPackage, fetchurl, isInsiders ? false }:

let
  inherit (stdenv.hostPlatform) system;

  plat = { x86_64-linux = "linux-x64"; }.${system};

  archive_fmt = "tar.gz";

  sha256 = {
    x86_64-linux = "sha256-jDD936sLQDtouBUeeaPCzLSj1Euo4GPA+Vf5ARZecs0=";
  }.${system};
in callPackage ./generic.nix rec {
  version = "1.52.1";
  pname = "vscode";

  executableName = "code" + lib.optionalString isInsiders "-insiders";
  longName = "Visual Studio Code" + lib.optionalString isInsiders " - Insiders";
  shortName = "Code" + lib.optionalString isInsiders " - Insiders";

  src = fetchurl {
    name = "VSCode_${version}_${plat}.${archive_fmt}";
    url = "https://vscode-update.azurewebsites.net/${version}/${plat}/stable";
    inherit sha256;
  };

  sourceRoot = "";

  meta = with lib; {
    description = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS
    '';
    longDescription = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS. It includes support for debugging, embedded Git
      control, syntax highlighting, intelligent code completion, snippets,
      and code refactoring. It is also customizable, so users can change the
      editor's theme, keyboard shortcuts, and preferences
    '';
    homepage = "https://code.visualstudio.com/";
    downloadPage = "https://code.visualstudio.com/Updates";
    license = licenses.unfree;
    maintainers = with maintainers; [ davegallant ];
    platforms = [ "x86_64-linux" ];
  };
}
