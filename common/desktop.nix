{...}: {
  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = false;
      };
    };
    desktopManager = {
      gnome = {
        enable = true;
      };
    };
  };

  services.logrotate.checkConfig = false;
}
