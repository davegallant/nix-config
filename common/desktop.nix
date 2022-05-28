{...}: {
  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
      gdm = {
        enable = true;
        wayland = false;
      };
    };
    desktopManager.gnome.enable = true;
  };

  services.logrotate.checkConfig = false;
}
