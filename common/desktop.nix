{...}: {
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = false;
      };
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
