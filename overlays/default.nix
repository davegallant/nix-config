final: prev: {

  lpass = prev.callPackage ./lastpass { };
  rfd = prev.callPackage ./rfd { };
  srv = prev.callPackage ./srv { };
  vpngate = prev.callPackage ./vpngate { };

  spotify-unwrapped =
    # Get latest edge: 
    # curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/spotify?channel=edge' | jq '.download_url,.version,.last_updated'
    prev.spotify-unwrapped.overrideAttrs (oldAttrs: {
      version = "1.1.52.687.gf5565fe5";
      src = prev.fetchurl {
        url =
          "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_44.snap";
        sha512 =
          "sha512-HIN8n25n4gSlsZQBGr9N+qaIxhN3xh8+2AttTzeAT1DQTVDIhAZ4UclGDURpYVpY1zuCJPvHG7knUkJ4hukXGQ==";
      };
      unpackPhase = ''
        runHook preUnpack
        unsquashfs "$src" '/usr/share/spotify' '/usr/bin/spotify' '/meta/snap.yaml'
        cd squashfs-root
        if ! grep -q '${final.spotify-unwrapped.version}' meta/snap.yaml; then
          echo "Package version differs from version found in snap metadata:"
          grep 'version: ' meta/snap.yaml
          echo "While the nix package specifies: ${final.spotify-unwrapped.version}."
          echo "You probably chose the wrong revision or forgot to update the nix version."
          exit 1
        fi
        runHook postUnpack
      '';
    });

}
