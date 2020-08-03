self: super:
rec {

  python38 = with super; super.python38.override { };

  pythonPackages = python38.pkgs;

  rfd = with self; pythonPackages.buildPythonApplication rec {
    pname = "rfd";
    version = "v0.4.0";

    src = fetchFromGitHub {
      owner = "davegallant";
      repo = "rfd";
      rev = version;
      hash = "sha256:0pr3ic4g5ccaqaqqpns5jc1lpilidx49380gnycrznghp3vqjsl1";
    };

    postPatch = ''
      substituteInPlace requirements.txt --replace "soupsieve<=2.0" "soupsieve"
      substituteInPlace requirements.txt --replace "beautifulsoup4<=4.8.2" "beautifulsoup4"
    '';

    # No tests included
    doCheck = false;

    propagatedBuildInputs = with pythonPackages; [
      beautifulsoup4
      click
      colorama
      requests
      soupsieve
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
