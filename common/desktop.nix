{...}: {
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
      };
      gdm = {
        enable = false;
        wayland = true;
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
