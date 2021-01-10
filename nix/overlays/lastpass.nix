self: super:
rec {

  lpass = with self; stdenv.mkDerivation rec {
    pname = "lpass";
    version = "1.3.4-unreleased";

    src = fetchFromGitHub {
      owner = "lastpass";
      repo = "lastpass-cli";
      rev = "8767b5e53192ad4e72d1352db4aa9218e928cbe1";
      sha256 = "sha256:1d4m5h9byq5cccdg98m8d8457rbvp28q821d8rpglykgrfgnknwp";
    };

    nativeBuildInputs = [ asciidoc cmake docbook_xsl pkgconfig ];

    buildInputs = [
      bash-completion curl openssl libxml2 libxslt
    ];

    enableParallelBuilding = true;

    installTargets = [ "install" "install-doc" ];

    postInstall = ''
      install -Dm644 -T ../contrib/lpass_zsh_completion $out/share/zsh/site-functions/_lpass
      install -Dm644 -T ../contrib/completions-lpass.fish $out/share/fish/vendor_completions.d/lpass.fish
    '';

    meta = with lib; {
      description = "Stores, retrieves, generates, and synchronizes passwords securely";
      homepage    = "https://github.com/lastpass/lastpass-cli";
      license     = licenses.gpl2Plus;
      platforms   = platforms.unix;
    };
  };
}
