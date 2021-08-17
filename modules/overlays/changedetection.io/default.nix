{ lib, fetchFromGitHub, python3, substituteAll }:

let
  py = python3.override {
    packageOverrides = self: super: {
      jsonpath-ng = super.buildPythonPackage rec {
        pname = "jsonpath-ng";
        doCheck = false;
        propagatedBuildInputs = with py.pkgs; [ decorator ply six wtforms ];
        version = "1.5.3";
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-onOxgqgsElbaq4ajE7k3BZJhtcX4xPo/w4uIKzRN1Wc=";
        };
      };
      timeago = super.buildPythonPackage rec {
        pname = "timeago";
        version = "1.0.15";
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-z85CDYKJKvayQ50Pae6z6Ha77dq2Zww8iOv3Z2QHv0w=";
        };
      };
      flask = super.buildPythonPackage rec {
        pname = "Flask";
        version = "1.1.4";
        propagatedBuildInputs = with py.pkgs; [ click jinja2 itsdangerous werkzeug ];
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-D762GA04OpGG0NbtlU4AQq2fGODo3giLK0GdUmkn0ZY=";
        };
      };
      click = super.buildPythonPackage rec {
        pname = "click";
        version = "7.1.2";
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-0rUlXHxjSbwb0eWeCM0SrLvWPOZJ8liHVXg6qU37axo=";
        };
      };
      jinja2 = super.buildPythonPackage rec {
        pname = "Jinja2";
        version = "2.11.3";
        propagatedBuildInputs = with py.pkgs; [ markupsafe ];
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-ptWEM94K6AA0fKsfowQ867q+i6qdKeZo8cdoy4ejM8Y=";
        };
      };
      itsdangerous = super.buildPythonPackage rec {
        pname = "itsdangerous";
        version = "1.1.0";
        propagatedBuildInputs = with py.pkgs; [ markupsafe ];
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-MhsDPQfypBNtPsdi6snxahDM1g9TwMka+QIXrOe6Hxk=";
        };
      };
      werkzeug = super.buildPythonPackage rec {
        pname = "Werkzeug";
        version = "1.0.1";
        doCheck = false;
        propagatedBuildInputs = with py.pkgs; [ markupsafe ];
        src = super.fetchPypi {
          inherit version pname;
          sha256 = "sha256-bICx5a02ZSkOo5MguR4b4eDV9gZSuWSjBwIW3oPS5Hw=";
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
in
with py.pkgs;
buildPythonApplication rec {
  pname = "changedetection.io";
  version = "0.39";

  src = fetchFromGitHub {
    owner = "dgtlmoon";
    repo = "changedetection.io";
    rev = "a11b6daa2e24933d0a3b9548a02d57c96ed0c09e";
    hash = "sha256-IdPlYa0lBI9xr+ywHuQ3OgNGvvKUIZf/wZ0ITbt2TyM=";
  };

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "chardet==2.3.0" "chardet" \
      --replace "selenium ~= 3.141" "selenium"
  '';

  propagatedBuildInputs = with py.pkgs; [
    apprise
    beautifulsoup4
    chardet
    eventlet
    feedgen
    flask
    flask_login
    inscriptis
    jsonpath-ng
    pytest
    pytest-flask
    pytz
    requests
    selenium
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
