{
  config,
  lib,
  pkgs,
  ...
}:
let
  litra-autotoggle = pkgs.callPackage ./litra-autotoggle/package.nix { };
  logPath = "${config.home.homeDirectory}/Library/Logs/litra-autotoggle.log";
in
lib.mkIf pkgs.stdenv.isDarwin {
  home.packages = [ litra-autotoggle ];

  launchd.agents.litra-autotoggle = {
    enable = true;
    config = {
      ProgramArguments = [ (lib.getExe litra-autotoggle) ];
      KeepAlive = true;
      ProcessType = "Background";
      RunAtLoad = true;
      StandardErrorPath = logPath;
      StandardOutPath = logPath;
    };
  };
}
