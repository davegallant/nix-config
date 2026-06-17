{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) stdenv;

  ryujinxRoot =
    if stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/Ryujinx"
    else
      "${config.home.homeDirectory}/.config/Ryujinx";

  stignore = ''
    !bis
    !bis/user
    !bis/user/**
    !bis/system
    !bis/system/save
    !bis/system/save/**

    *
  '';
in
{
  home.activation.ryujinxStignore = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu

    mkdir -p "${ryujinxRoot}"
    printf '%s' ${lib.escapeShellArg stignore} > "${ryujinxRoot}/.stignore"
  '';
}
