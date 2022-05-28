final: prev: {

  aws-connect = prev.callPackage ./aws-connect { };
  aws-role-play = prev.callPackage ./aws-role-play { };
  keyleds = prev.callPackage ./keyleds { };
  lpass = prev.callPackage ./lastpass { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  tmux-sessionizer = prev.callPackage ./tmux-sessionizer { };
  vpngate = prev.callPackage ./vpngate { };
  yar = prev.callPackage ./yar { };

}
