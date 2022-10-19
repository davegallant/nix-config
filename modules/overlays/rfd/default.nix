{
  lib,
  fetchFromGitHub,
  python3,
}: let
  py = python3.override {};
in
  with py.pkgs;
    buildPythonApplication rec {
      pname = "rfd";
      version = "v0.9.0";
      format = "pyproject";

      src = fetchFromGitHub {
        owner = "davegallant";
        repo = "rfd";
        rev = version;
        hash = "sha256-lxSd30zh10IIsWkVm5Zm5GR0sieYPaS4QDTqu3ICz8s=";
      };

      # No tests included
      doCheck = false;

      nativeBuildInputs = [poetry];

      propagatedBuildInputs = with py.pkgs; [
        beautifulsoup4
        click
        colorama
        requests
        soupsieve
      ];

      passthru.python3 = python3;

      meta = with lib; {
        homepage = "https://www.redflagdeals.com/";
        description = "View RedFlagDeals from the command line";
        license = licenses.gpl3;
      };
    }
