final: prev: {

  aws-connect = prev.callPackage ./aws-connect { };
  lpass = prev.callPackage ./lastpass { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  vpngate = prev.callPackage ./vpngate { };
  changedetection.io = prev.callPackage ./changedetection.io { };

}
