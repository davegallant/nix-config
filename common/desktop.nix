{...}: {
  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
      /*
       gdm = {
       */
      /*
       enable = true;
       */
      /*
       wayland = false;
       */
      /*
       };
       */
      lightdm = {
        enable = true;
      };
    };
    desktopManager.gnome.enable = true;
  };

  services.logrotate.checkConfig = false;
}
