final: prev: {

  g810-led = prev.callPackage ./g810-led { };
  lpass = prev.callPackage ./lastpass { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  vpngate = prev.callPackage ./vpngate { };
  vscode = prev.callPackage ./vscode { };

}
