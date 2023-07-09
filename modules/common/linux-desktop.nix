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

  services.gnome.gnome-keyring.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
