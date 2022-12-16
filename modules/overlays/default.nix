final: prev: {
  rfd = prev.callPackage ./rfd {};
  srv = prev.callPackage ./srv {};
  tmux-sessionizer = prev.callPackage ./tmux-sessionizer {};
  vpngate = prev.callPackage ./vpngate {};
  yar = prev.callPackage ./yar {};
}
