{
  pkgs,
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation rec {
  name = "keyleds";
  version = "1.1.1";

  src = fetchFromGitHub {
    name = "source-${name}-${version}";
    owner = "keyleds";
    repo = "keyleds";
    rev = "v${version}";
    sha256 = "sha256-KCWmaRmJTmZgTt7HW9o6Jt1u4x6+G2j6T9EqVt21U18=";
  };

  postInstall = ''
    cat <<EOF >> $out/bin/set-leds.sh
    #!/usr/bin/env bash

    for d in \$($out/bin/keyledsctl list); do
      $out/bin/keyledsctl set-leds -d \$d all=black|| true;
    done
    EOF

    chmod +x $out/bin/set-leds.sh
  '';

  nativeBuildInputs = with pkgs; [cmake pkg-config];
  buildInputs = with pkgs; [xlibsWrapper xorg.libXi libuv systemd luajit libyaml];
}
