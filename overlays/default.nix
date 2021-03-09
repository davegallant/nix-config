final: prev: {

  lpass = prev.callPackage ./lastpass { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  vpngate = prev.callPackage ./vpngate { };

}
