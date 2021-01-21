{ lib, fetchFromGitHub, python3, }:

let py = python3.override { };

in with py.pkgs;
buildPythonApplication rec {
  pname = "rfd";
  version = "v0.6.0";

  src = fetchFromGitHub {
    owner = "davegallant";
    repo = "rfd";
    rev = version;
    hash = "sha256:0cllhbca4dykl6j8snmml4kk6kzamlzhcrdf49f5v0zk7zljgkl1";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace "soupsieve<=2.0" "soupsieve"
    substituteInPlace requirements.txt --replace "beautifulsoup4<=4.8.2" "beautifulsoup4"
  '';

  # No tests included
  doCheck = false;

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
    license = licenses.asl20;
    maintainers = [ ];
  };
}
