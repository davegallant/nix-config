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
      version = "v0.8.1";
      format = "pyproject";

      src = fetchFromGitHub {
        owner = "davegallant";
        repo = "rfd";
        rev = version;
        hash = "sha256-9gOxrKVEqbg2vLO5opoetVSxgwpm/3SV60mK8Le6F48=";
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
