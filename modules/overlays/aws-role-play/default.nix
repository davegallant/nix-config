{ lib, fetchFromGitHub, python3 }:

let
  py = python3.override {
    packageOverrides = self: super: {
      prettycolors = super.buildPythonPackage rec {
        pname = "pretty-colors";
        version = "1.2.23";
        doCheck = false;
        src = fetchFromGitHub {
          owner = "onelivesleft";
          repo = "PrettyErrors";
          rev = "8b58260f00b0aab789e940f5ee190fa9c3c10925";
          sha256 = "sha256-ICFwaRkQ30/sml4GuzXF8TyJAg+ZXnLmKGil18KisUw=";
        };
        propagatedBuildInputs = [ py.pkgs.colorama ];
      };
    };
  };
in
with py.pkgs;
buildPythonApplication rec {
  pname = "aws-role-play";
  version = "419e0de612554bfce467da4896e1abcadb78c406";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "rewindio";
    repo = "aws-role-play";
    rev = version;
    hash = "sha256-o+u/ixL48J2WMWFRkOlWGvXMVwn+BrofzlspOVwmnCo=";
  };

  # No tests included
  doCheck = false;

  nativeBuildInputs = [ poetry ];

  propagatedBuildInputs = with py.pkgs; [
    boto3
    click
    colorama
    prettycolors
  ];

  passthru.python3 = python3;

  meta = with lib; {
    homepage = "https://www.rewind.com/";
    description = "A CLI tool that makes assuming IAM roles and exporting temporary credentials easier";
    license = licenses.mit;
    maintainers = [ davegallant ];
  };
}
