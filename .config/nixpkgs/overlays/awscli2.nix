self: super:
rec {
  python3 = with super; super.python3.override {
    packageOverrides = self: super: {
      botocore = super.botocore.overridePythonAttrs (oldAttrs: rec {
        version = "2.0.0dev19";
        src = fetchFromGitHub {
          owner = "boto";
          repo = "botocore";
          rev = "ce7b76d296b345d7647f50557606947ad857a786";
          sha256 = "0g9pvcs94v2znjkzzjnz30021q9bm97fxmlhxvql6im3c6adrqb3";
        };
      });
      prompt_toolkit = super.prompt_toolkit.overridePythonAttrs (oldAttrs: rec {
        version = "2.0.10";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "1nr990i4b04rnlw1ghd0xmgvvvhih698mb6lb6jylr76cs7zcnpi";
        };
      });
    };
  };

  pythonPackages = python3.pkgs;

  awscli2 = with self; pythonPackages.buildPythonApplication rec {
    pname = "awscli";
    version = "2.0.15"; # N.B: if you change this, change botocore to a matching version too

    src = fetchFromGitHub {
      owner = "aws";
      repo = "aws-cli";
      rev = version;
      sha256 = "030pw7aa1y13awrpwlsq3ib633fh1z4rzkz8b31x7jg7s1hxrsvr";
    };

    postPatch = ''
      substituteInPlace setup.py --replace ",<0.16" ""
      substituteInPlace setup.py --replace "cryptography>=2.8.0,<=2.9.0" "cryptography>=2.8.0,<2.10"
    '';

    # No tests included
    doCheck = false;

    propagatedBuildInputs = with pythonPackages; [
      bcdoc
      botocore
      colorama
      cryptography
      docutils
      groff
      less
      prompt_toolkit
      pyyaml
      rsa
      ruamel_yaml
      s3transfer
      six
    ];

    postInstall = ''
      mkdir -p $out/etc/bash_completion.d
      echo "complete -C $out/bin/aws_completer aws" > $out/etc/bash_completion.d/awscli
      mkdir -p $out/share/zsh/site-functions
      mv $out/bin/aws_zsh_completer.sh $out/share/zsh/site-functions
      rm $out/bin/aws.cmd
    '';

    passthru.python3 = python3; # for aws_shell

    meta = with super.lib; {
      homepage = "https://aws.amazon.com/cli/";
      description = "Unified tool to manage your AWS services";
      license = licenses.asl20;
      maintainers = [ ];
    };
  };
}
