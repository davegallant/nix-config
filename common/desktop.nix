{ ... }:

{

  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = false;
    nvidiaWayland = false;
  };
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "dave";
    job.preStart = "sleep 5";
  };

}
