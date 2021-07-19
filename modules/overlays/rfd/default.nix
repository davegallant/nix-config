{ lib, fetchFromGitHub, python3 }:

let py = python3.override { };

in
with py.pkgs;
buildPythonApplication rec {
  pname = "rfd";
  version = "v0.7.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "rfd";
    rev = version;
    hash = "sha256-LW/iXAmq59xxIxqx9RaMLe0L6DFkkcm/+hTq8UgjyQM=";
  };

  # No tests included
  doCheck = false;

  nativeBuildInputs = [ poetry ];

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
    maintainers = [ davegallant ];
  };
}
