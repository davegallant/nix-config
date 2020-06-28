self: super:
rec {

  python38 = with super; super.python38.override { };

  pythonPackages = python38.pkgs;

  rfd = with self; pythonPackages.buildPythonApplication rec {
    pname = "rfd";
    version = "v0.3.4";

    src = fetchFromGitHub {
      owner = "davegallant";
      repo = "rfd";
      rev = version;
      sha256 = "08f9xsw5h35p5sbljrv7vrzvdz17icgr85n7507p27fcg0yphd0s";
    };

    # No tests included
    doCheck = false;

    propagatedBuildInputs = with pythonPackages; [
      beautifulsoup4
      click
      colorama
      requests
    ];

    passthru.python3 = python3;

    meta = with super.lib; {
      homepage = "https://www.redflagdeals.com/";
      description = "View RedFlagDeals from the command line";
      license = licenses.asl20;
      maintainers = [ ];
    };
  };
}
