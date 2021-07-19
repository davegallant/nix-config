final: prev: {

  aws-connect = prev.callPackage ./aws-connect { };
  lpass = prev.callPackage ./lastpass { };
  changedetection.io = prev.callPackage ./changedetection.io { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  vpngate = prev.callPackage ./vpngate { };
  yar = prev.callPackage ./yar { };

  # overrides
  neovim = prev.pkgs.neovim-nightly;

}
