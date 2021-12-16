final: prev: {

  aws-connect = prev.callPackage ./aws-connect { };
  aws-role-play = prev.callPackage ./aws-role-play { };
  changedetection.io = prev.callPackage ./changedetection.io { };
  lpass = prev.callPackage ./lastpass { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  tmux-sessionizer = prev.callPackage ./tmux-sessionizer { };
  vpngate = prev.callPackage ./vpngate { };
  yar = prev.callPackage ./yar { };

  # overrides
  neovim = prev.pkgs.neovim-nightly;

}
