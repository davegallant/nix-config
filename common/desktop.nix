{...}: {
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
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
