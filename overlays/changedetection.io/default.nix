{ lib, fetchFromGitHub, python3, substituteAll }:

let
  py = python3.override {
    packageOverrides = self: super: {
      timeago = super.buildPythonPackage rec {
        pname = "timeago";
        version = "1.0.15";
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-z85CDYKJKvayQ50Pae6z6Ha77dq2Zww8iOv3Z2QHv0w=";
        };
      };
      inscriptis = super.buildPythonPackage rec {
        pname = "inscriptis";
        version = "1.2";
        propagatedBuildInputs = with py.pkgs; [ lxml requests ];
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-B2lFW/YwzCVdR8lwV9VGEW9HRfIii8u48Sy0wK+XeWY=";
        };
      };
    };
  };
in with py.pkgs;
buildPythonApplication rec {
  pname = "changedetection.io";
  version = "0.30";

  src = fetchFromGitHub {
    owner = "dgtlmoon";
    repo = "changedetection.io";
    rev = "1d66160e8c9bd3cef8e1727fe66572f8b5065757";
    hash = "sha256-J0J6Jj9f2FD2aH4RWR1VnarX1vqnb5T6YmycxhzuyDw=";
  };

  patches = [ (substituteAll { src = ./setup.patch; }) ];

  propagatedBuildInputs = with py.pkgs; [
    apprise
    chardet
    eventlet
    feedgen
    flask
    flask_login
    inscriptis
    pytest
    pytest-flask
    pytz
    requests
    timeago
    urllib3
    validators
  ];

  meta = with lib; {
    description =
      "changedetection.io - The best and simplest self-hosted website change detection monitoring service";
    homepage = "https://github.com/dgtlmoon/changedetection.io";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
